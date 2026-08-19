module icp.filters.nofilter;

import icp.image;
import icp.filters.ifilter;

/// Filter that does nothing. Made for tests!!
public @filter final class NoFilter : IFilter
{
    public Image filter(const Image image)
    {
        return image.dup;
    }
}