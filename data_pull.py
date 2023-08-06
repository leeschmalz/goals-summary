from get import getExistAttribute
from datetime import datetime
import csv

running = getExistAttribute('workouts_distance', count=9999)
weight_lifting = getExistAttribute('weight_lifting', count=9999)
reading = getExistAttribute('pages_read', count=9999)
alcohol = getExistAttribute('alcoholic_drinks', count=9999)

rows = []
for attribute, values in zip(
    ['running', 'weight_lifting', 'reading', 'alcohol'],
    [running, weight_lifting, reading, alcohol]
):
    for entry in values:
        date = entry['date']
        value = entry['value']
        rows.append({'date': date, 'attribute': attribute, 'value': value})

with open(f"goals_data_{datetime.now().strftime('%Y-%m-%d')}.csv", 'w', newline='') as csvfile:
    fieldnames = ['date', 'attribute', 'value']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    for row in rows:
        writer.writerow(row)