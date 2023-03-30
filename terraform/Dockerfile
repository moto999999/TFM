FROM hashicorp/terraform:1.3.8

ENV GOOGLE_APPLICATION_CREDENTIALS=/infra/tfm-uc3m-365809-dbee44e928c4.json

RUN apk add bash

WORKDIR /infra 

COPY ./certificates /certificates
COPY ./ssh_key /ssh_key

COPY ./terraform/gcp /infra

ENTRYPOINT ["terraform"] 
CMD ["plan"]