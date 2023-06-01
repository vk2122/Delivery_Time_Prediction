from flask import Flask, request, jsonify
import pandas as pd
import pickle
import xgboost as xgb

app = Flask(__name__)

filename = 'D:/Delivery_Time_Prediction/model/timePred.pkl'
with open(filename, 'rb') as file:
    loaded_model = pickle.load(file)


@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()

    input_df = pd.DataFrame(data)

    predictions = loaded_model.predict(input_df)

    response = {'predictions': predictions.tolist()}
    return jsonify(response)


if __name__ == '__main__':
    app.run(debug=True)
