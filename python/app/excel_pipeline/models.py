from dataclasses import dataclass
from enum import Enum
from typing import List, Optional, Tuple


class SheetType(str, Enum):
    TABULAR = "tabular"
    SEMI_STRUCTURED = "semi_structured"
    UNSTRUCTURED = "unstructured"
    EMPTY = "empty"


@dataclass
class TableBoundary:
    start_row: int
    start_col: int
    end_row: int
    end_col: int
    header_row: Optional[int] = None
    has_row_labels: bool = False
    confidence: float = 1.0


@dataclass
class SheetAnalysis:
    sheet_type: SheetType
    table_regions: List[TableBoundary]
    metadata_regions: List[Tuple[int, int, int, int]]
    merged_cells: List[str]
    data_density: float
    max_row: int
    max_col: int
