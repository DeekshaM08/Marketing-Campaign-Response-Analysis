import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score

# Step 1: Load the data
df = pd.read_csv("Marketing Campaign (Converted).csv")

# Step 2: Clean data
df.replace(' ', np.nan, inplace=True)
df.drop(columns=['Dt_Customer'], errors='ignore', inplace=True)
df = df.apply(pd.to_numeric, errors='ignore')
df.fillna(0, inplace=True)

# ✅ FIXED: Convert Active/Inactive BEFORE splitting
df['Active_Inactive'] = df['Active_Inactive'].map({'Active': 1, 'Inactive': 0})

# Step 3: One-hot encode
df_encoded = pd.get_dummies(df,
    columns=['Age_Group', 'Income_Bracket', 'Education', 'Marital_Status'],
    drop_first=True
)

# Step 4: Define X and y again after all transformations
X = df_encoded.drop('Response', axis=1)
y = df_encoded['Response']

# (Optional) Check for remaining non-numeric columns
print("Non-numeric columns:\n", X.dtypes[X.dtypes == 'object'])

# Step 5: Train-test split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42, stratify=y
)

# Step 6: Scale features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Step 7: Train logistic regression model
model = LogisticRegression(max_iter=5000, solver='saga', random_state=42)
model.fit(X_train_scaled, y_train)

# Predict class labels
y_pred = model.predict(X_test_scaled)

# Predict probabilities (for ROC AUC score)
y_prob = model.predict_proba(X_test_scaled)[:, 1]

from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score

# Classification report
print("📄 Classification Report:\n", classification_report(y_test, y_pred))

# Confusion matrix
print("🧮 Confusion Matrix:\n", confusion_matrix(y_test, y_pred))

# ROC AUC Score
print("📈 ROC AUC Score:", round(roc_auc_score(y_test, y_prob), 3))

df_encoded['Predicted_Response'] = model.predict(scaler.transform(X))
df_encoded['Predicted_Probability'] = model.predict_proba(scaler.transform(X))[:, 1]

# Save to CSV for Tableau
df_encoded.to_csv("Customer_Response_Model_Output.csv", index=False)



