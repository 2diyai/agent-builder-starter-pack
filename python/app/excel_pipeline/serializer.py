from typing import Any, Dict, List, Optional


class JsonFormat:
    OBJECT = "object"
    FLAT = "flat"
    HYBRID = "hybrid"


class LLMJsonSerializer:
    def __init__(self, json_format: str = JsonFormat.HYBRID, max_rows: Optional[int] = None):
        self.json_format = json_format
        self.max_rows = max_rows

    def serialize_sheet(self, sheet_data: Dict[str, Any]) -> Dict[str, Any]:
        sheet_type = sheet_data.get("type")
        if sheet_type == "tabular":
            return self._serialize_tabular(sheet_data)

        if sheet_type == "semi_structured":
            return self._serialize_semi_structured(sheet_data)

        return sheet_data

    def _serialize_tabular(self, sheet_data: Dict[str, Any]) -> Dict[str, Any]:
        headers: List[str] = sheet_data.get("headers", [])
        rows = sheet_data.get("data", [])
        sampled_rows, truncated_info = self._apply_row_limit(rows)

        if self.json_format == JsonFormat.OBJECT:
            object_rows = [self._to_object_row(headers, row) for row in sampled_rows]
            result = {
                "type": "tabular",
                "metadata": sheet_data.get("structure", {}),
                "data": object_rows,
            }
            result.update(truncated_info)
            return result

        if self.json_format == JsonFormat.FLAT:
            flat_rows = [self._to_flat_row(headers, row) for row in sampled_rows]
            result = {"type": "tabular", "schema": headers, "rows": flat_rows}
            result.update(truncated_info)
            return result

        hybrid_rows = [self._to_flat_row(headers, row) for row in sampled_rows]
        result = {
            "type": "tabular",
            "structure": {
                "columns": [{"name": header, "index": idx} for idx, header in enumerate(headers)],
                "row_count": len(rows),
            },
            "data": hybrid_rows,
        }
        result.update(truncated_info)
        return result

    def _serialize_semi_structured(self, sheet_data: Dict[str, Any]) -> Dict[str, Any]:
        tables = []
        for table in sheet_data.get("tables", []):
            tables.append(self._serialize_tabular(table))

        return {
            "type": "semi_structured",
            "metadata": sheet_data.get("metadata", {}),
            "tables": tables,
            "annotations": sheet_data.get("annotations", []),
            "merged_cells": sheet_data.get("merged_cells", []),
        }

    def _to_object_row(self, headers: List[str], row: Dict[str, Any]) -> Dict[str, Any]:
        result: Dict[str, Any] = {}
        for header in headers:
            cell_payload = row.get(header, {})
            result[header] = cell_payload.get("value")
        return result

    def _to_flat_row(self, headers: List[str], row: Dict[str, Any]) -> List[Any]:
        flat_values: List[Any] = []
        for header in headers:
            cell_payload = row.get(header, {})
            flat_values.append(cell_payload.get("value"))
        return flat_values

    def _apply_row_limit(self, rows: List[Dict[str, Any]]) -> tuple[List[Dict[str, Any]], Dict[str, Any]]:
        if not self.max_rows or len(rows) <= self.max_rows:
            return rows, {}

        first_n = max(self.max_rows // 3, 1)
        middle_n = max(self.max_rows // 3, 1)
        last_n = max(self.max_rows - first_n - middle_n, 1)

        middle_start = max((len(rows) // 2) - (middle_n // 2), 0)
        sampled = rows[:first_n] + rows[middle_start : middle_start + middle_n] + rows[-last_n:]

        return sampled, {
            "truncated": True,
            "original_row_count": len(rows),
            "returned_row_count": len(sampled),
        }
