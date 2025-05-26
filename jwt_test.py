import jwt
import time

payload = {
    "sub": "admin",
    "iat": int(time.time()),
    "exp": int(time.time()) + 3600
}

secret = "ThisIsASecretKeyThatIsAtLeast32Bytes!"
token = jwt.encode(payload, secret, algorithm="HS256")

print(token)
