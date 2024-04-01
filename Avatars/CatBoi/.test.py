import json
from typing import Any
import os
from pathlib import Path
from rich import inspect, print as pprint
json_data: dict[str, Any] = {}

with Path(os.getcwd(), "CatBoi - Copy.bbmodel.bak").open(mode="r", encoding="utf-8") as file:
    json_data = json.loads(file.read())

for index, element in enumerate(json_data["elements"]):
    if element["name"] in ["Fluffy","Tail Overlay","Overlay","Base","Tail Cube 5","Tail Cube 4","Tail Cube 3","Tail Cube 2","Tail Cube 1","Tip"]:
        for heading, direction in element["faces"].items():
            if direction["texture"] != 2:
                #pprint(f"Texture was not 2: elements[{index}].{element['name']}.{heading}.texture = {direction['texture']}")
                continue
            else:
                for uv_index, uv in enumerate(direction["uv"]):
                    json_data["elements"][index]["faces"][heading]["uv"][uv_index] = (uv * 0.75)
                    #pprint(f"Set uv at \"elements[{index}].{element['name']}.{heading}.uv[{uv_index}]\" from {uv} to {(uv * 0.75)}")

with Path(os.getcwd(), "CatBoi.bbmodel").open(mode="w", encoding="utf-8") as file:
    file.write(json.dumps(json_data))