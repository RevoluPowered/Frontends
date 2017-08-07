import csv
from psutil import cpu_percent


def log_cpu_usage():
    """ writes cpu usage to csv """
    with open('cpu_percentage.csv', 'a') as file:
        serialiser = csv.writer(file)
        serialiser.writerow(cpu_percent(interval=1, percpu=True))


log_cpu_usage()
print("Finished logging cpu usage to CSV.")
