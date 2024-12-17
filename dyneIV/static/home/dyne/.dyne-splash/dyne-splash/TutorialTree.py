# Copyright Lorenzo L. Ancora - 2024.
# Licensed under the European Union Public License 1.2
# SPDX-License-Identifier: EUPL-1.2
# Created for the Dynebolic project.

from typing import List, Dict
from warnings import warn
from pathlib import Path
from threading import Thread, Lock


class TutorialTree(object):
    __threadLock: Lock = None
    

    def __init__(self, tree_path: str):
        self.tree_path: Path = Path(tree_path)


    def getPagesTree(self) -> Dict[str, str]:
        if self.tree_path.is_file():
            return [str(self.tree_path)]
        elif not self.tree_path.exists():
            warn(message=f"missing tutorial tree: {str(self.tree_path)} does not exist.", category=UserWarning)
            return []

        if TutorialTree.__threadLock is None:
            TutorialTree.__threadLock = Lock()

        stree: List[str] = list()

        def iter_fs(tree_path: Path, dst_list: List[str]):
            tree: List[Path]

            with TutorialTree.__threadLock:
                tree = tree_path.rglob("**/*.html")
                for path in tree:
                    dst_list.append(str(path))

        t = Thread(target=iter_fs, daemon=True, kwargs={"tree_path": self.tree_path, "dst_list": stree})
        t.start()
        t.join(timeout=5.0)
        
        return stree