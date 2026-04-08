# Amazon-Brazil-E-Commerce-Analysis-PostgreSQL
An end-to-end analysis of Amazon Brazil's e-commerce data focusing on payment behavior, customer segmentation, and seasonal sales trends using PostgreSQL.
#  Trends & Customer Behavior Analysis

## Project Overview
This project analyzes an Amazon Brazil e-commerce dataset using **PostgreSQL** to extract business-critical insights. The analysis is divided into payment behavior, product performance, and customer loyalty segmentation.

## Key Insights
* [cite_start]**Payment Trends:** Credit cards are the most popular payment method [cite: 14, 26] [cite_start]and yield the highest average payment value[cite: 14].
* [cite_start]**Customer Segmentation:** The majority of customers are "Occasional" users [cite: 236][cite_start], but there is a distinct group of "Loyal" customers who have placed up to 16 orders[cite: 130, 142].
* [cite_start]**Seasonal Sales:** Total sales peak during the **Spring** season[cite: 181].
* [cite_start]**Revenue Drivers:** The "Beleza Saude" (Health & Beauty) category generates the highest total revenue[cite: 159].

## Technical SQL Features Used
* [cite_start]**Window Functions:** Utilized `SUM(...) OVER()` for percentage calculations [cite: 19] [cite_start]and `DENSE_RANK()` for customer ranking[cite: 253].
* [cite_start]**CTEs & Recursion:** Used Common Table Expressions for segmentation [cite: 75, 221] [cite_start]and a **Recursive CTE** for monthly cumulative sales[cite: 262].
* [cite_start]**Data Cleansing:** Identified and quantified 614 products with missing category names[cite: 72].

## Recommendations
* [cite_start]Focus on understanding seasonal patterns to prepare for demand fluctuations[cite: 47, 183].
