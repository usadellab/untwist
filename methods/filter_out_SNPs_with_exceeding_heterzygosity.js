// Taken from here:
// https://www.biostars.org/p/235149/
// (last accessed on 04/19/23)
function accept(v)
    {
    var heterocygosity_threshold = 0.5;
    var nhet=0.0;
    var nhomref=0;
    var nhomvar=0;
    for(var i=0;i< v.getNSamples();++i)
        {
        var g= v.getGenotype(i);
        if(g.isHet())  nhet++;
        if(g.isHomRef())  nhomref++;
        if(g.isHomVar())  nhomvar++;
        }
    return(nhet/v.getNSamples() < heterocygosity_threshold && nhomref>0 && nhomvar>0);
    }
accept(variant);
