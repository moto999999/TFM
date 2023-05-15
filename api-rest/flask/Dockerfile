FROM python:alpine3.17
EXPOSE 5000

RUN apk add git

ENV FLASK_APP=prometheus

WORKDIR /app
COPY requirements.txt /app

RUN pip3 install -r requirements.txt --no-cache-dir

COPY ./ /app/

ENTRYPOINT ["flask"] 
CMD ["run", "--host=0.0.0.0"]
