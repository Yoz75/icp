module icp.filtreg;
import icp.filters.ifilter : filter;
import icp.filters.bwfilter;
import icp.filters.nofilter;
import std.traits;
import std.meta;
import std : AliasSeq;

/// A useless thing, we need it only to emulate hash set in `globalComponents`
struct Dummy
{

}

/// All found components
public __gshared Dummy[string] globalAllFilters;

/// Default modules, that contain components
public alias DefaultModules = AliasSeq!(icp.filters.nofilter, icp.filters.bwfilter);

public alias FoundFilters = staticMap!(registerModule, DefaultModules);

/// Get all component structs in a module `name` as AliasSeq(filters...).
/// This template returns types, that contain `filter` attribute, but `filter` itself
public template getFiltersInModule(alias name)
{
    alias getFiltersInModule = getSymbolsByUDA!(name, filter);
}

public template registerModule(alias name)
{
    alias registerModule = getFiltersInModule!(name);
}