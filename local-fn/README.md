# Local AWS SAM function

From this directory, run:

```bash
sam local invoke HelloWorldFunction
sam local invoke HelloWorldFunction -e events/event.json
```

Optional HTTP test in a second terminal while `sam local start-api` runs:

```bash
sam local start-api
# In another terminal:
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/hello
```

Expected handler result includes `"statusCode": 200` and `"message":"hello world"`. This requires locally installed AWS SAM CLI and a running Docker Engine, but **no AWS account**.
