FROM hashicorp/terraform:1.4.6

RUN apk add python3 py3-pip

WORKDIR /infra 

COPY ./api-rest/terraform-docker/requirements.txt /infra
RUN pip3 install -r requirements.txt --no-cache-dir

COPY ./api-rest/terraform-docker/download_code.py /infra

ENTRYPOINT ["python3"] 
CMD ["download_code.py"]