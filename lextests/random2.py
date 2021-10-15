import random

c = ["a", '"', " "]

output = ""

for i in range(1000):
    length = int(random.randint(0, 20))

    for u in range(length):
        output += random.choice(c)
    
    output += '\n'

print(output)