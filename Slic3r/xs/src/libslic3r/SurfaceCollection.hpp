#ifndef slic3r_SurfaceCollection_hpp_
#define slic3r_SurfaceCollection_hpp_

#include "Surface.hpp"
#include <vector>

namespace Slic3r {

class SurfaceCollection
{
    public:
    Surfaces surfaces;
    
    operator Polygons() const;
    operator ExPolygons() const;
    void simplify(double tolerance);
    void group(std::vector<SurfacesPtr> *retval);
};

}

#endif
