" Vim syntax file
"
" Copyright (C) 2004  Chris Larson <kergoth@handhelds.org>
" This file is licensed under the MIT license, see COPYING.MIT in
" this source distribution for the terms.
"
" Language:	BitBake
" Maintainer:	Chris Larson <kergoth@handhelds.org>
" Filenames:	*.bb, *.bbclass

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn case match

syn match bbComment		"^#.*$" display contains=bbTodo
syn keyword bbTodo		TODO FIXME XXX contained
syn match bbDelimiter		"[(){}=]" contained
syn match bbQuote		/['"]/ contained

"syn region bbString		matchgroup=bbQuote start=/"/ skip=/\\$/ excludenl end=/"/ keepend contains=bbTodo
"syn region bbString		matchgroup=bbQuote start=/'/ skip=/\\$/ excludenl end=/'/ keepend contains=bbTodo
syn region bbString		matchgroup=bbQuote start=/"/ skip=/\\$/ excludenl end=/"/ contained keepend contains=bbTodo
syn region bbString		matchgroup=bbQuote start=/'/ skip=/\\$/ excludenl end=/'/ contained keepend contains=bbTodo

" First attempt:
" syn keyword bbPythonFlag	python contained nextgroup=bbFunction
" syn region bbPythonFuncRegion	start="^python\s\+\w\+\s*()\s*{" end="^}$" keepend contains=bbPythonFuncDef
" syn match bbPythonFuncDef	"^python\s\+\w\+\s*()\s*{" contained contains=bbPythonFlag
" hi def link bbPythonFuncRegion	Comment
" hi def link bbPythonFlag	Type

" Second attempt:
" syn keyword bbPythonFlag	python contained nextgroup=bbFunction
" syn match bbPythonFuncDef	"^python\s\+\w\+\s*()\s*{" contained contains=bbPythonFlag,bbFunction,bbDelimiter
" syn region bbPythonFuncRegion	start="^python\s\+\w\+\s*()\s*{" end="^}$" keepend contains=bbPythonFuncDef,bbDelimiter
" hi def link bbPythonFuncRegion	Comment
" hi def link bbPythonFlag	Type

" Third attempt:
" syn keyword bbPythonFlag	python contained nextgroup=bbFunction
" syn match bbPythonFuncDef	"^\(python\s\+\w\+\s*()\s*\)\({\)\@=" contains=bbPythonFlag,bbFunction,bbDelimiter nextgroup=bbPythonFuncRegion
" syn region bbPythonFuncRegion	matchgroup=bbDelimiter start="{" end="^}$" keepend contained
" hi def link bbPythonFuncRegion	Comment
" hi def link bbPythonFlag	Type

" BitBake variable metadata
syn match bbVarDef		"^\([a-zA-Z0-9\-_]\+\)\s*\(=\)\@=" contains=bbIdentifier nextgroup=bbVarEq
syn match bbIdentifier		"[a-zA-Z0-9\-_]\+" display contained
"syn keyword bbVarEq	= display contained nextgroup=bbVarValue
syn match bbVarEq		"=" contained contains=bbOperator nextgroup=bbVarValue
syn match bbVarValue		".*$" contained contains=bbString


" BitBake variable metadata flags
syn match bbVarFlagDef		"^\([a-zA-Z0-9\-_]\+\)\(\[[a-zA-Z0-9\-_]\+\]\)\@=" contains=bbIdentifier nextgroup=bbVarFlagFlag
syn region bbVarFlagFlag	matchgroup=bbArrayBrackets start="\[" end="\]\s*\(=\)\@=" keepend excludenl contained contains=bbIdentifier nextgroup=bbVarEq
"syn match bbVarFlagFlag		"\[\([a-zA-Z0-9\-_]\+\)\]\s*\(=\)\@=" contains=bbIdentifier nextgroup=bbVarEq


" Functions!
syn match bbFunction	"\h\w*" display contained


" BitBake python metadata
syn include @python syntax/python.vim
if exists("b:current_syntax")
  unlet b:current_syntax
endif

syn keyword bbPythonFlag	python contained nextgroup=bbFunction
syn match bbPythonFuncDef	"^\(python\s\+\)\(\w\+\)\?\(\s*()\s*\)\({\)\@=" contains=bbPythonFlag,bbFunction,bbDelimiter nextgroup=bbPythonFuncRegion
syn region bbPythonFuncRegion	matchgroup=bbDelimiter start="{" end="^}$" keepend contained contains=@python
"hi def link bbPythonFuncRegion	Comment


" BitBake shell metadata
syn include @shell syntax/sh.vim
if exists("b:current_syntax")
  unlet b:current_syntax
endif

syn match bbShellFuncDef	"^\(\w\+\)\(python\)\@<!\(\s*()\s*\)\({\)\@=" contains=bbFunction,bbDelimiter nextgroup=bbShellFuncRegion
syn region bbShellFuncRegion	matchgroup=bbDelimiter start="{" end="^}$" keepend contained contains=@shell
"hi def link bbShellFuncRegion	Comment


" BitBake 'def'd python functions
syn keyword bbDef	def	contained

syn match bbDefCmd		"^def" contains=bbDef skipwhite nextgroup=bbDefFunc
syn match bbDefFunc		"\w\+" contains=bbFunction contained skipwhite nextgroup=bbDefArgs
syn region bbDefArgs		matchgroup=bbDelimiter start="(" end=")" excludenl contained skipwhite keepend contains=bbIdentifier nextgroup=bbDefRegion
syn region bbDefRegion		matchgroup=bbDelimiter start=":$" end='^$' end='^\(\s\)\@!' contained contains=@python


" BitBake statements
syn keyword bbStatement		include inherit addtask addhandler

syn match bbArrayBrackets	"[\[\]]" contained
hi def link bbArrayBrackets	Statement

hi def link bbDef		Statement
hi def link bbPythonFlag	Type
hi def link bbStatement		Statement
hi def link bbString		String
hi def link bbTodo		Todo
hi def link bbComment		Comment
hi def link bbOperator		Operator
hi def link bbError		Error
hi def link bbFunction		Function
hi def link bbDelimiter		Delimiter
hi def link bbIdentifier	Identifier
hi def link bbQuote		Statement
hi def link bbVarEq		Operator

let b:current_syntax = "bb"
