# pull docker image with python version
FROM python:3.11

# install necessary components
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev 
    
# set the working directory to the app folder
WORKDIR /home/app

# copy files from guest to the host
COPY . /home/app

# Install dependencies
COPY ./docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

# install modules for django application
RUN pip install -r requirements.txt

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000

# run server on port 8000
CMD ["python","manage.py", "runserver","0.0.0.0:8000"]
