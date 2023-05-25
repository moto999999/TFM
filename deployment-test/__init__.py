from flask import Flask, request, abort
from .dbController import dbController
from .utils.dataValidatorAPI import dataValidatorAPI
from .makePrediction import makePrediction
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": ["http://webapp.k8s-tfm.tk"]}})

MAX_DATA = 1000
DB_NAME = "/app/app/resources/db/stock_database.db"
MODEL_PATH = "/app/app/resources/model/myModel.pt"
SCALER_PATH = "/app/app/resources/scaler/scaler.skl"

_db = dbController(DB_NAME, MAX_DATA)
_predictionMaker = makePrediction(MODEL_PATH, SCALER_PATH)
_validator = dataValidatorAPI()

# Manejador error 404
@app.errorhandler(404)
def not_found(error):
    error.description = "El servicio que ha solicitado no existe"
    return error.description, 404

# Manejador error 400
@app.errorhandler(400)
def not_found(error):
    return error.description, 400

# Manejador error 500
@app.errorhandler(500)
def not_found(error):
    return error.description, 500

@app.route("/getPrediction", methods=["GET"])
def getPrediction():
    if(request.args):
        date = request.args.get("fecha")
        nPredicciones = request.args.get("nPredicciones")

        _validator.dateValidator(date, _db.getMinDate(), _db.getMaxDate())
        _validator.nPredictionsValidator(nPredicciones, MAX_DATA)

        dateId = _db.getIdByDate(date)

        _validator.intervalValidator(int(nPredicciones), dateId, _db.getMaxId(), date, _db.getMaxDate())

        nPredicciones = int(nPredicciones)
        data =  _db.getDataById(dateId, nPredicciones)

        return _predictionMaker.makePrediction(data, nPredicciones)

    else: return abort(400, description = "No se han enviado parametros")

@app.route("/getPoint", methods=["GET"])
def getPoint():
    if(request.args):
        date = request.args.get("fecha")
        nPredicciones = request.args.get("nPredicciones")

        _validator.dateValidator(date, _db.getMinDate(), _db.getMaxDate())
        _validator.nPredictionsValidator(nPredicciones, MAX_DATA)

        dateId = _db.getIdByDate(date)

        _validator.intervalValidator(int(nPredicciones), dateId, _db.getMaxId(), date, _db.getMaxDate())

        nPredicciones = int(nPredicciones)
        return _db.getDateCloseById(dateId, nPredicciones)

    else: return abort(400, description = "No se han enviado parametros")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=False)