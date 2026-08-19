module icp.filters.ifilter;
import icp.image;

// currently unused, needed for custom presets supporting (I hope i'll add it)
/// Attribute that tells that class is a filter
public struct filter
{
}

/// Something that processes (filters) an image and returns a new one based on previous160
public interface IFilter
{
    /// Filer an image somehow
    /// Returns: filtered image
    public Image filter(const Image);
}