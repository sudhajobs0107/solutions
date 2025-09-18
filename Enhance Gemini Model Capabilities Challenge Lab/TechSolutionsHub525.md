# ✨Enhance Gemini Model Capabilities: Challenge Lab || GSP525 ✨
<div align="center">
<a href="https://www.cloudskillsboost.google/focuses/121451?parent=catalog" target="_blank" rel="noopener noreferrer" style="text-decoration: none;">
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
<p><strong>☁️ Follow video and Run in Cloud Shell :-</strong></p>

## Go to `Vertex AI` → `Workbench` → Open `JupyterLab` → Open `enhance-gemini-model-capabilities-v2.0.0.ipynb`

## `Task 1`
## Update the `Region`

## `Task 2`
```
Code == Tool(code_execution=ToolCodeExecution())

Remove the prompt = f"""what is the average price of sneakers in {sneaker_prices}
Generate and run code for the calculation."""
```
## `Task 3`
```
google_search_tool = Tool(google_search=GoogleSearch())

update the prompt = " What are the key features of the Nike Air Jordan XXXVI? "

Config = GenerateContentConfig(tools=[google_search_tool])
```
## `Task 4`
```
Query remove the starting lines & add = f"{model} price at {retailer}" 
response_schema = response_schema,
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

