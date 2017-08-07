import csv
import asyncio
from psutil import cpu_percent

async def log_cpu():
    """ async logger of CPU usage """
    while True:
        with open('./static/data/cpu_percentage.csv', 'a') as file:
            serialiser = csv.writer(file)
            serialiser.writerow(cpu_percent(interval=1, percpu=True))
        await asyncio.sleep(0.5)

loop = asyncio.get_event_loop()
loop.run_until_complete(log_cpu())
loop.close()
print("Finished logging cpu usage to CSV.")
