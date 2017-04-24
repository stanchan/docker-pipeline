import io

def plugins(filename):
    with io.open(filename, "r", encoding="utf-8") as f:
        data = f.read().splitlines()
    return data