syn match colon ':' nextgroup=projectPath skipwhite
syn match projectPath contained '[^"]*'
syn match projectName '^[^:]*' skipwhite nextgroup=colon
syn match comment '".*'

hi def link projectPath String
hi def link projectName Constant
hi def link comment Comment
hi def link colon Comment
