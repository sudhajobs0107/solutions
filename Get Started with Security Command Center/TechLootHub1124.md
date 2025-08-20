# ✨Get Started with Security Command Center || GSP1124 ✨
<div align="center">
<a href="https://www.cloudskillsboost.google/focuses/71933?parent=catalog" target="_blank" rel="noopener noreferrer" style="text-decoration: none;">
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
<p><strong>☁️ Run in Cloud Shell:</strong></p>

```bash
curl -LO raw.githubusercontent.com/sudhajobs0107/solutions/refs/heads/main/Get%20Started%20with%20Security%20Command%20Center/techloothub1124.sh
sudo chmod +x techloothub1124.sh
./techloothub1124.sh
```
</div>

<div style="padding: 15px; margin: 10px 0;">
<p><strong>💡 After scoring `90/100` in the lab, run the below commands and follow the video instructions</strong></p>

```bash
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

gcloud compute instances stop eth-mainnet-rpc-node --project=$DEVSHELL_PROJECT_ID --zone=$ZONE && gcloud compute instances set-machine-type eth-mainnet-rpc-node --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=e2-standard-4 && gcloud compute instances start eth-mainnet-rpc-node --project=$DEVSHELL_PROJECT_ID --zone=$ZONE
```
</div>

---

## 🎉 **Congratulations! Lab Completed Successfully!** 🏆  

<div align="center" style="padding: 5px;">
  <h3>📱 Join the TechLootHub Community</h3>
  
  <a href="https://www.youtube.com/@techloothub">
    <img src="https://img.shields.io/badge/Subscribe-TechLootHub-FF0000?style=for-the-badge&logo=youtube&logoColor=white" alt="YouTube Channel">
  </a>
  &nbsp;
  <a href="https://www.linkedin.com/in/sudhajobs0107/">
    <img src="https://img.shields.io/badge/LINKEDIN-Sudha%20Yadav-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn">
</a>


</div>

---

<div align="center">
  <p style="font-size: 12px; color: #586069;">
    <em>This guide is provided for educational purposes. Always follow Qwiklabs terms of service and YouTube's community guidelines.</em>
  </p>
</div>

