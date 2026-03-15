import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import psycopg2
from pathlib import Path

# Dynamic file path
project_root = Path(__file__).resolve().parents[1]

# SQL helper function
def read_sql(path, conn):
    with open(path) as f:
        query = f.read()
    return pd.read_sql(query, conn)

# Chart №1: maket structure
def generate_figure_01(conn):
    # Load results of the query into a dataframe
    sql_path = project_root / "sql" / "13_route_competition_summary_us_distribution.sql"
    df = read_sql(sql_path, conn)

    # Build chart
    fig, ax = plt.subplots(figsize = (7, 3))
    sns.barplot(
        data = df,
        x = "routes",
        y = "route_competition",
        ax = ax,
        color = "#7db6a3"
    )

    # Titles
    ax.set_title("Most Short-Haul US Routes Are Monopolies or Duopolies (2024)", fontweight = "bold")
    ax.set_xlabel("Number of Routes")
    ax.set_ylabel("")

    # Labels
    total = df["routes"].sum()
    labels = [f"{v} ({v/total:.1%})" for v in df["routes"]]
    ax.bar_label(ax.containers[0], labels = labels, padding = 8)

    # Design
    ax.grid(axis = "x", linestyle = "--", alpha = 0.2)
    ax.grid(axis = "y", visible = False)
    sns.despine()

    # Show, save and close
    plt.tight_layout(rect = [0, 0, 1, 0.92])
    plt.show()
    output_path = project_root / "figures" / "fig01_route_competition_distribution.png"
    fig.savefig(output_path, dpi = 300, bbox_inches = "tight")
    plt.close(fig)

# Chart №2: concentration by carrier count
def generate_figure_02(conn):
    # Load results of the query into a dataframe
    sql_path = project_root / "sql" / "18_route_competition_and_hhi_matrix.sql"
    df = read_sql(sql_path, conn)

    # Pivot data from long to wide format
    df = (
        df.pivot(index = "route_competition", columns = "hhi_ranking", values = "routes")
          .fillna(0)
          .reindex(["duopoly", "competitive"])
    )

    # Reorder columns in df (for chart legend)
    df = df[["low", "moderate", "high"]]

    # Build chart
    custom_colors = ["#D1EBEB", "#469B9D", "#004D4F"]
    ax = df.plot.bar(
        stacked = True,
        rot = 0,
        figsize = (7, 5),
        color = custom_colors
    )
    fig = ax.get_figure()

    # Titles
    ax.set_title("Routes with Multiple Carriers Still Show High Concentration (2024)", fontweight = "bold")
    ax.set_xlabel("")
    ax.set_ylabel("")

    # Design
    ax.grid(axis = "x", visible = False)
    ax.grid(axis = "y", linestyle = "--", alpha = 0.2)
    ax.set_ylim(0, 480)
    sns.despine()

    # Bar labels
    totals = df.sum(axis = 1)
    for i, total in enumerate(totals):
        ax.text(i, total + 5, f"{int(total)}", ha = "center")

    # Legend
    ax.legend(
        title = "HHI Bucket",
        fontsize = 9,
        title_fontsize = 10,
        frameon = False
    )

    # Show, save and close
    plt.tight_layout(rect = [0, 0, 1, 0.92])
    plt.show()
    output_path = project_root / "figures" / "fig02_hhi_distribution_by_competition_bucket.png"
    fig.savefig(output_path, dpi = 300, bbox_inches = "tight")
    plt.close(fig)

# Chart №3: "competitive" routes by their HHI
def generate_figure_03(conn):
    # Load results of the query into a dataframe
    sql_path = project_root / "sql" / "17_share_of_competitive_routes_with_high_hhi.sql"
    df = read_sql(sql_path, conn)

    # Build chart
    dark = "#8bb3b4"
    light = "#b0d2cf"

    fig, ax = plt.subplots(figsize = (9, 3))
    sns.barplot(
        data = df,
        x = "pct_routes",
        y = "concentration_group",
        ax = ax,
        height = 0.5,
        color = light
    )

    # Recolor bars
    max_value = df["pct_routes"].max()
    for patch, value in zip(ax.patches, df["pct_routes"]):
        patch.set_facecolor(dark if value == max_value else light)

    # Titles
    ax.set_title("Most “Competitive” Short-Haul Routes Remain Highly Concentrated (2024)", fontweight = "bold")
    ax.set_xlabel("Share of competitive routes (%)")
    ax.set_ylabel("")

    # Labels
    total = df["routes"].sum()
    labels = [f"{v} ({v/total:.1%})" for v in df["routes"]]
    ax.bar_label(ax.containers[0], labels = labels, padding = 8)

    # Design
    ax.grid(axis = "x", linestyle = "--", alpha = 0.2)
    ax.grid(axis = "y", visible = False)
    sns.despine()

    # Show, save and close
    plt.tight_layout(rect = [0, 0, 1, 0.92])
    plt.show()
    output_path = project_root / "figures" / "fig03_share_of_competitive_routes_with_high_hhi.png"
    fig.savefig(output_path, dpi = 300, bbox_inches = "tight")
    plt.close(fig)

# Generate all 3 charts
if __name__ == "__main__":
    # Set chart style
    sns.set_style("whitegrid")

    # Open connection
    conn = psycopg2.connect(
        host="localhost",
        database="air_travel_us_2024",
        user="shevelov"
    )

    # Call chart functions
    generate_figure_01(conn)
    generate_figure_02(conn)
    generate_figure_03(conn)

    # Close connection
    conn.close()