from flask import Flask, request, jsonify
import pandas as pd
import pickle
import xgboost as xgb

app = Flask(__name__)

# Load the saved model from the pickle file
filename = 'D:/Delivery_Time_Prediction/model/timePred.pkl'
with open(filename, 'rb') as file:
    loaded_model = pickle.load(file)


@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()

    # Create a DataFrame from the input data
    input_df = pd.DataFrame(data)

    # Make predictions using the loaded model and input data
    predictions = loaded_model.predict(input_df)

    # Return the predictions as a JSON response
    response = {'predictions': predictions.tolist()}
    return jsonify(response)


if __name__ == '__main__':
    app.run(debug=True)