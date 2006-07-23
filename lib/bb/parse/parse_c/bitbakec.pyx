# ex:ts=4:sw=4:sts=4:et
# -*- tab-width: 4; c-basic-offset: 4; indent-tabs-mode: nil -*-

cdef extern from "stdio.h":
    ctypedef int FILE
    FILE *fopen(char*, char*)
    int fclose(FILE *fp)

cdef extern from "string.h":
    int strlen(char*)

cdef extern from "lexerc.h":
    ctypedef struct lex_t:
        void* parser
        void* scanner
        FILE* file
        void* data

    int lineError
    int errorParse

    cdef extern void parse(FILE*, object)

def parsefile(object file, object data):
    #print "parsefile: 1", file, data

    # Open the file
    cdef FILE* f

    f = fopen(file, "r")
    #print "parsefile: 2 opening file"
    if (f == NULL):
        raise IOError("No such file %s." % file)

    #print "parsefile: 3 parse"
    parse(f, data)

    # Close the file
    #print "parsefile: 4 closing"
    fclose(f)


cdef public void e_assign(lex_t* container, char* key, char* what):
    #print "e_assign", key, what
    d = <object>container.data
    d.setVar(key, what)

cdef public void e_export(lex_t* c, char* what):
    #print "e_export", what
    #exp:
    # bb.data.setVarFlag(key, "export", 1, data)
    d = <object>c.data
    d.setVarFlag(what, "export", 1)

cdef public void e_immediate(lex_t* c, char* key, char* what):
    #print "e_immediate", key, what
    #colon:
    # val = bb.data.expand(groupd["value"], data)
    d = <object>c.data
    d.setVar(key, d.expand(what,None))

cdef public void e_cond(lex_t* c, char* key, char* what):
    #print "e_cond", key, what
    #ques:
    # val = bb.data.getVar(key, data)
    # if val == None:    
    #    val = groupd["value"]
    d = <object>c.data
    d.setVar(key, (d.getVar(key,0) or what))

cdef public void e_prepend(lex_t* c, char* key, char* what):
    #print "e_prepend", key, what
    #prepend:
    # val = "%s %s" % (groupd["value"], (bb.data.getVar(key, data) or ""))
    d = <object>c.data
    d.setVar(key, what + " " + (d.getVar(key,0) or ""))

cdef public void e_append(lex_t* c, char* key, char* what):
    #print "e_append", key, what
    #append:
    # val = "%s %s" % ((bb.data.getVar(key, data) or ""), groupd["value"])
    d = <object>c.data
    d.setVar(key, (d.getVar(key,0) or "") + " " + what)

cdef public void e_precat(lex_t* c, char* key, char* what):
    #print "e_precat", key, what
    #predot:
    # val = "%s%s" % (groupd["value"], (bb.data.getVar(key, data) or ""))
    d = <object>c.data
    d.setVar(key, what + (d.getVar(key,0) or ""))

cdef public void e_postcat(lex_t* c, char* key, char* what):
    #print "e_postcat", key, what
    #postdot:
    # val = "%s%s" % ((bb.data.getVar(key, data) or ""), groupd["value"])
    d = <object>c.data
    d.setVar(key, (d.getVar(key,0) or "") + what)

cdef public void e_addtask(lex_t* c, char* name, char* before, char* after):
    #print "e_addtask", name
    # func = m.group("func")
    # before = m.group("before")
    # after = m.group("after")
    # if func is None:
    #     return
    # var = "do_" + func
    #
    # data.setVarFlag(var, "task", 1, d)
    #
    # if after is not None:
    # #  set up deps for function
    #     data.setVarFlag(var, "deps", after.split(), d)
    # if before is not None:
    # #   set up things that depend on this func
    #     data.setVarFlag(var, "postdeps", before.split(), d)
    # return

    do = "do_%s" % name
    d = <object>c.data
    d.setVarFlag(do, "task", 1)

    if before != NULL and strlen(before) > 0:
        #print "Before", before
        d.setVarFlag(do, "postdeps", ("%s" % before).split())
    if after  != NULL and strlen(after) > 0:
        #print "After", after
        d.setVarFlag(do, "deps", ("%s" % after).split())


cdef public void e_addhandler(lex_t* c, char* h):
    #print "e_addhandler", h
    # data.setVarFlag(h, "handler", 1, d)
    d = <object>c.data
    d.setVarFlag(h, "handler", 1)

cdef public void e_export_func(lex_t* c, char* function):
    #print "e_export_func", function
    pass

cdef public void e_inherit(lex_t* c, char* file):
    #print "e_inherit", file
    pass

cdef public void e_include(lex_t* c, char* file):
    from bb.parse import handle
    d = <object>c.data

    try:
        handle(d.expand(file,d), d, True)
    except IOError:
        print "Could not include file", file


cdef public void e_require(lex_t* c, char* file):
    #print "e_require", file
    from bb.parse import handle
    d = <object>c.data

    try:
        handle(d.expand(file,d), d, True)
    except IOError:
        print "ParseError", file
        from bb.parse import ParseError
        raise ParseError("Could not include required file %s" % file)

cdef public void e_proc(lex_t* c, char* key, char* what):
    #print "e_proc", key, what
    pass

cdef public void e_proc_python(lex_t* c, char* key, char* what):
    #print "e_proc_python"
    if key != NULL:
        pass
        #print "Key", key
    if what != NULL:
        pass
        #print "What", what
    pass

cdef public void e_proc_fakeroot(lex_t* c, char* key, char* what):
    #print "e_fakeroot", key, what
    pass

cdef public void e_def(lex_t* c, char* a, char* b, char* d):
    #print "e_def", a, b, d
    pass

cdef public void e_parse_error(lex_t* c):
    print "e_parse_error", "line:", lineError, "parse:", errorParse


    from bb.parse import ParseError
    raise ParseError("There was an parse error, sorry unable to give more information at the current time.")

