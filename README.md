# SQL Case Study: Paintings Dataset (Kaggle)

This project is an **end-to-end SQL case study** using the [Kaggle Paintings Dataset](https://www.kaggle.com/) to explore artworks, artists, museums, and pricing details.  
The analysis focuses on **data quality checks, business-driven queries, and insights** into the art ecosystem.

---

## 📊 Project Overview

The dataset contains information on:

- **Artists** (name, nationality, style)
- **Paintings** (title, style, subject, size, price)
- **Museums** (location, hours, country)
- **Canvas Sizes & Product Prices**

Using SQL, I performed **exploratory analysis and data cleaning**, then solved **21 business questions** to derive actionable insights.

---

## 🛠️ Skills & Concepts Demonstrated

- **Data Cleaning & Validation**
  - Detecting invalid city names and duplicate museum hours  
  - Identifying missing or inconsistent records  

- **SQL Querying Techniques**
  - Joins, CTEs, Subqueries  
  - Window Functions: `RANK`, `ROW_NUMBER`, `DENSE_RANK`  
  - Aggregations and grouping logic  

- **Business-Oriented Analytics**
  - Museum popularity rankings  
  - Artist contributions across countries  
  - Painting pricing insights (discounts, most/least expensive works)  
  - Operational analytics on museum hours  

---

## 🔍 Key Insights

Some highlights from the analysis:

- ✅ **0 museums without paintings** – every museum has at least one work.  
- 💰 Identified paintings priced at **>100% markup** or **>50% discount** vs. regular price.  
- 🖼️ **Top 5 most popular artists** by painting count revealed global trends in art production.  
- 🏛️ Museums were ranked by **number of paintings** and **operating hours**.  
- 🌍 Found artists whose works are displayed **across multiple countries**.  
- 🎭 Identified the **3 most popular** and **3 least popular painting styles**.  

---

## 📂 Repository Structure

