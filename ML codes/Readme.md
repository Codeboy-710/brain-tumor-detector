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

## ⚙️ Tech Stack  
- TensorFlow / Keras  
- DenseNet201 (Transfer Learning)  
- NumPy / Pandas  
- Scikit-learn  
- Matplotlib  
- OpenCV / PIL  

 ## **Classes:**
  - Glioma Tumor
  - Meningioma Tumor
  - Pituitary Tumor
  - No Tumor
  <br><br>

## 📊 Dataset

Due to size constraints, the dataset is not included in this repository.

You can download it from:
👉 https://www.kaggle.com/datasets/tombackert/brain-tumor-mri-data  


## ⚙️ Preprocessing

- Image resizing: `150 x 150`
- Normalization: pixel values scaled to `[0,1]`
- Data augmentation applied (if used)

---

## 🧠 Model Training & Export

Follow these steps to generate the trained model and TensorFlow Lite file.  
## 1️⃣:- **Install dependencies**
```bash
pip install -r requirements.txt
```
## 2️⃣:- **Prepare dataset**

Place dataset in the following structure:  
Training/  
    glioma_tumor/  
    meningioma_tumor/  
    pituitary_tumor/  
    no_tumor/  

Testing/  
    glioma_tumor/  
    meningioma_tumor/  
    pituitary_tumor/  
    no_tumor/  

## 3️⃣:- 🚀**Run the Project**
<br>>
You can run this project using either Jupyter Notebook / VS Code/ Google Colab.
<br><br>
▶️ Option 1:-  Jupyter Notebook(Local)
<br><br>
Install Jupyter (if not installed):  
```bash
pip install notebook
```
1. Open terminal and run:
```bash
jupyter notebook
```
2. Open:
```bash
DenseNet.ipynb
```
3. Run all cells sequentially from top to bottom.  

<br><br>
▶️ Option 2:-  VS Code (Recommended) 
<br>
1. Open the project folder in VS Code:
```bash
code .
```
2. Open DenseNet.ipynb  
3. Select a Python kernel (install Jupyter extension if needed)  
4. Run cells step-by-step or use:
```bash
Run All
```
▶️ Option 3: Google Colab (Easiest / No Setup)
<br><br>
   1. Upload DenseNet.ipynb to Google Colab:  
   👉 https://colab.research.google.com
   <br><br>
   2. Mount your dataset (if using Google Drive):
   ```bash
from google.colab import drive
drive.mount('/content/drive')
   ```
   3. Update dataset paths in notebook:
```bash
Training = "/content/drive/MyDrive/Training"
Testing = "/content/drive/MyDrive/Testing"
```
4. Run all cells sequentially.
<br><br>
## 🔄 What the Notebook Does

When executed, the notebook performs the following pipeline:

- Loads MRI image dataset from /Training and /Testing
- Preprocesses images (resize to 150×150, normalize to [0,1])
- Encodes labels using one-hot encoding
- Applies data augmentation:
- Rotation
- Zoom
- Horizontal & vertical flip
- Shifting
- Splits data into training and validation sets
- Loads pretrained DenseNet201 (ImageNet weights)
- Adds custom classification layers:
- Dense(128, ReLU), Dense(4, Softmax)
- Trains the model using Adam optimizer
- Evaluates performance using classification report
- Plots accuracy and loss curves  

<br><br>
## 4️⃣:- 💾 **Model Output/Saving**  
After training, the model is saved as:
```bash
hist.h5
```
## 5️⃣:- **Convert model to TensorFlow Lite**
The trained model is converted into TensorFlow Lite format for mobile deployment:
```bash
model.tflite
```
This file is used inside the Flutter application for on-device inference.
<br><br>
## 6️⃣:- **Use in Flutter App**  
Copy model.tflite into the assests folder:
```bash
assets/
```
Update pubspec.yaml accordingly.
