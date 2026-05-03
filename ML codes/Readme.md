# 🧠 Brain Tumor Detection - ML Model

This folder contains the machine learning pipeline used to train the brain tumor classification model deployed in the Flutter application.

---

## 📌 Model Overview

- **Task:** Multi-class Brain Tumor Classification
- **Architectures Explored:**
  - DenseNet (primary model used in deployment)
  - EfficientNet
  - MobileNet
  - U-Net (used for segmentation experiments)

- **Final Deployed Model:** DenseNet-based CNN (converted to TensorFlow Lite)

- **Classes:**
  - Glioma Tumor
  - Meningioma Tumor
  - Pituitary Tumor
  - No Tumor

## 📊 Dataset

Due to size constraints, the dataset is not included in this repository.

You can download it from:
👉 https://www.kaggle.com/datasets/tombackert/brain-tumor-mri-data

---

## ⚙️ Preprocessing

- Image resizing: `150 x 150`
- Normalization: pixel values scaled to `[0,1]`
- Data augmentation applied (if used)

---

## 🏋️ Training

To train the model:

```bash
  use the python codes of the respective model you want to use.
  Debug and run it step by step and complete the test, train & graph processes 



  📦 Model Export

  After training, the model is converted to TensorFlow Lite format:
  '''bash
  - model.tflite

  This file is used inside the Flutter application.
  (P.S:- It can be from any respective model whichever gives highest accuracy)