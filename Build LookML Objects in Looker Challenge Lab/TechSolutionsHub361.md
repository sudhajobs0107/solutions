# ✨Build LookML Objects in Looker: Challenge Lab || GSP361 ✨
<div align="center">
<a href="https://www.cloudskillsboost.google/focuses/25703?parent=catalog" target="_blank" rel="noopener noreferrer" style="text-decoration: none;">
    <img src="https://img.shields.io/badge/Open_Lab-Cloud_Skills_Boost-4285F4?style=for-the-badge&logo=google&logoColor=white&labelColor=34A853" alt="Open Lab" style="height: 35px; border-radius: 5px;">
  </a>
</div>

---

## ⚠️ Disclaimer ⚠️

> **Educational Purpose Only:** This script and guide are intended *solely for educational purposes* to help you understand Google Cloud monitoring services and advance your cloud skills. Before using, please review it carefully to become familiar with the services involved.
>
> **Terms Compliance:** Always ensure compliance with Qwiklabs' terms of service and YouTube's community guidelines. The aim is to enhance your learning experience—*not* to circumvent it.

---

## ⚙️ Lab Environment Setup

<div style="padding: 15px; margin: 10px 0;">
<p><strong>☁️ Follow video instructions :-</strong></p>

# 🚀 Looker Lab Instructions

## 📌 Phase 1:- LookML File Updates

✅ Step 1: Create New File `order_items_challenge.view`

```

view: order_items_challenge {
  sql_table_name: `cloud-training-demos.looker_ecomm.order_items`  ;;
  drill_fields: [order_item_id]
  dimension: order_item_id {
  primary_key: yes
  type: number
  sql: ${TABLE}.id ;;
  }

  dimension: is_search_source {
  type: yesno
  sql: ${users.traffic_source} = "Search" ;;
  }


  measure: sales_from_complete_search_users {
  type: sum
  sql: ${TABLE}.sale_price ;;
  filters: [is_search_source: "Yes", order_items.status: "Complete"]
  }


  measure: total_gross_margin {
  type: sum
  sql: ${TABLE}.sale_price - ${inventory_items.cost} ;;
  }


  dimension: return_days {
  type: number
  sql: DATE_DIFF(${order_items.delivered_date}, ${order_items.returned_date}, DAY);;
  }
  dimension: order_id {
  type: number
  sql: ${TABLE}.order_id ;;
  }

}

```


✅ Step 2: Create New File `user_details.view`

```

view: user_details {
  derived_table: {
  explore_source: order_items {
    column: order_id {}
    column: user_id {}
    column: total_revenue {}
    column: age { field: users.age }
    column: city { field: users.city }
    column: state { field: users.state }
  }
  }
  dimension: order_id {
  description: ""
  type: number
  }
  dimension: user_id {
  description: ""
  type: number
  }
  dimension: total_revenue {
  description: ""
  value_format: "$#,##0.00"
  type: number
  }
  dimension: age {
  description: ""
  type: number
  }
  dimension: city {
  description: ""
  }
  dimension: state {
  description: ""
  }
}


```

✅ Step 3: Replace: `training_ecommerce.model`

> 📝 Note:<br>
> * Update the VALUE_1 with the FILTER #1 Value Provided in Lab<br>
> * Update the VALUE_2 with the FILTER #3 Value Provided in Lab



```

connection: "bigquery_public_data_looker"

# include all the views
include: "/views/*.view"
include: "/z_tests/*.lkml"
include: "/**/*.dashboard"

datagroup: training_ecommerce_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: training_ecommerce_default_datagroup

label: "E-Commerce Training"

explore: order_items {



  sql_always_where: ${sale_price} >= VALUE_1 ;;


  conditionally_filter: {

  filters: [order_items.shipped_date: "2018"]

  unless: [order_items.status, order_items.delivered_date]

  }


  sql_always_having: ${average_sale_price} > VALUE_2 ;;

  always_filter: {
  filters: [order_items.status: "Shipped", users.state: "California", users.traffic_source:
    "Search"]
  }



  join: user_details {

  type: left_outer

  sql_on: ${order_items.user_id} = ${user_details.user_id} ;;

  relationship: many_to_one

  }


  join: order_items_challenge {
  type: left_outer
  sql_on: ${order_items.order_id} = ${order_items_challenge.order_id} ;;
  relationship: many_to_one
  }

  join: users {
  type: left_outer
  sql_on: ${order_items.user_id} = ${users.id} ;;
  relationship: many_to_one
  }



  join: inventory_items {
  type: left_outer
  sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
  relationship: many_to_one
  }

  join: products {
  type: left_outer
  sql_on: ${inventory_items.product_id} = ${products.id} ;;
  relationship: many_to_one
  }

  join: distribution_centers {
  type: left_outer
  sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
  relationship: many_to_one
  }
}

explore: events {
  join: event_session_facts {
  type: left_outer
  sql_on: ${events.session_id} = ${event_session_facts.session_id} ;;
  relationship: many_to_one
  }
  join: event_session_funnel {
  type: left_outer
  sql_on: ${events.session_id} = ${event_session_funnel.session_id} ;;
  relationship: many_to_one
  }
  join: users {
  type: left_outer
  sql_on: ${events.user_id} = ${users.id} ;;
  relationship: many_to_one
  }
}


```


# ✅ Check: Task 1 to Task 3 Progress in Looker UI




## 🧩 Phase 2:- Advanced Model Update for Caching


✅ Step 4: Update `training_ecommerce.model`

> 📝 Note: Replace NUM with the # of hours value from Task 4 in the Lab Manual. It will take 5mins.

```

connection: "bigquery_public_data_looker"

# include all the views
include: "/views/*.view"
include: "/z_tests/*.lkml"
include: "/**/*.dashboard"

datagroup: order_items_challenge_datagroup {
  sql_trigger: SELECT MAX(order_item_id) from order_items ;;
  max_cache_age: "NUM hours"
}


persist_with: order_items_challenge_datagroup


label: "E-Commerce Training"

explore: order_items {
  join: user_details {

  type: left_outer

  sql_on: ${order_items.user_id} = ${user_details.user_id} ;;

  relationship: many_to_one

  }


  join: order_items_challenge {
  type: left_outer
  sql_on: ${order_items.order_id} = ${order_items_challenge.order_id} ;;
  relationship: many_to_one
  }

  join: users {
  type: left_outer
  sql_on: ${order_items.user_id} = ${users.id} ;;
  relationship: many_to_one
  }



  join: inventory_items {
  type: left_outer
  sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
  relationship: many_to_one
  }

  join: products {
  type: left_outer
  sql_on: ${inventory_items.product_id} = ${products.id} ;;
  relationship: many_to_one
  }

  join: distribution_centers {
  type: left_outer
  sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
  relationship: many_to_one
  }
}

explore: events {
  join: event_session_facts {
  type: left_outer
  sql_on: ${events.session_id} = ${event_session_facts.session_id} ;;
  relationship: many_to_one
  }
  join: event_session_funnel {
  type: left_outer
  sql_on: ${events.session_id} = ${event_session_funnel.session_id} ;;
  relationship: many_to_one
  }
  join: users {
  type: left_outer
  sql_on: ${events.user_id} = ${users.id} ;;
  relationship: many_to_one
  }
}


```

</div>

## 🎉 **Congratulations! Lab Completed Successfully!** 🏆  

<div align="center" style="padding: 5px;">
  <h3>📱 Join the TechSolutionsHub Community</h3>
  
  <a href="https://www.youtube.com/@techsolutionshub01">
    <img src="https://img.shields.io/badge/Subscribe-TechSolutionsHub-FF0000?style=for-the-badge&logo=youtube&logoColor=white" alt="YouTube Channel">
  </a>
  &nbsp;
  <a href="https://www.linkedin.com/in/sudha-yadav-devops-engineer/">
    <img src="https://img.shields.io/badge/LINKEDIN-Sudha%20Yadav-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn">
</a>


</div>

---

<div align="center">
  <p style="font-size: 12px; color: #586069;">
    <em>This guide is provided for educational purposes. Always follow Qwiklabs terms of service and YouTube's community guidelines.</em>
  </p>
</div>

