#!/bin/bash

PROJECT_NAME=$1

createStartScript() {
    env=$1

    echo "Creating Script for $env environment"

    if [[ "$env" == "dev" ]]
    then
        fileName="start-dev.sh"
        runCMD="pipenv run flask --debug run -h 0.0.0.0 -p 5001"
    elif [[ "$env" == "prod" ]]
    then
        fileName="start.sh"
        runCMD="pipenv run flask run -h 0.0.0.0"
    else
        echo "Env can be dev or prod."
        exit
    fi

    cat << EOF > "$fileName"
#!/bin/sh
export FLASK_APP=./services/routes.py
EOF

    echo "$runCMD" >> "$fileName"
}

if [[ -z "$PROJECT_NAME" ]]
then
    echo "Project Name is required. Usage bash setup-backend.sh 'project_name'"
    exit 1
elif [[ ! -d "$PROJECT_NAME" ]]
then
    echo "Project Folder should exists. Either created it or clone the repo in the current path"
    exit 1
fi

folders=(
    "services/main"
    "services/model"
)

files=(
    ".env"
    "services/main/__init__.py"
    "services/model/__init__.py"
    "services/__init__.py"
    "services/routes.py"
)

envs=(
    "dev"
    "prod"
)

cd $PROJECT_NAME

for folder in "${folders[@]}"; do
    if [[ ! -d "$folder" ]]
    then
        mkdir -p "$folder"
    fi
done

for file in "${files[@]}"; do
    if [[ ! -f "$file" ]]
    then
        touch "$file"
    fi

    if [[ "$file" == "services/routes.py" ]]
    then
        # Add dummy route
    cat << EOF > "$file"

from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "Hello, World!"
EOF

    fi
done

for env in "${envs[@]}"; do
    createStartScript "$env"
done

pip3 install pipenv

pipenv --python 3.10

pipenv install flask

pipenv install marshmallow
