# ✨Cloud Filestore: Qwik Start || GSP244 ✨
<div align="center">
<a href="https://www.cloudskillsboost.google/focuses/1802?parent=catalog" target="_blank" rel="noopener noreferrer" style="text-decoration: none;">
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

```
curl -LO raw.githubusercontent.com/sudhajobs0107/solutions/refs/heads/main/Cloud%20Filestore%20Qwik%20Start/techsolutionshub244.sh
sudo chmod +x techsolutionshub244.sh
./techsolutionshub244.sh
```
```
gcloud healthcare fhir-stores export bq de_id \
--dataset=$DATASET_ID \
--location=$LOCATION \
--bq-dataset=bq://$PROJECT_ID.de_id \
--schema-type=analytics
```
---
```
SELECT
  id AS patient_id,
  name[safe_offset(0)].given AS given_name,
  name[safe_offset(0)].family AS family,
  birthDate AS birth_date
FROM dataset1.Patient LIMIT 10
```
---
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

