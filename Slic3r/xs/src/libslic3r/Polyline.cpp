#include "Polyline.hpp"
#include "Polygon.hpp"

namespace Slic3r {

Polyline::operator Polylines() const
{
    Polylines polylines;
    polylines.push_back(*this);
    return polylines;
}

Point
Polyline::last_point() const
{
    return this->points.back();
}

Point
Polyline::leftmost_point() const
{
    Point p = this->points.front();
    for (Points::const_iterator it = this->points.begin() + 1; it != this->points.end(); ++it) {
        if (it->x < p.x) p = *it;
    }
    return p;
}

Lines
Polyline::lines() const
{
    Lines lines;
    if (this->points.size() >= 2) {
        lines.reserve(this->points.size() - 1);
        for (Points::const_iterator it = this->points.begin(); it != this->points.end()-1; ++it) {
            lines.push_back(Line(*it, *(it + 1)));
        }
    }
    return lines;
}

// removes the given distance from the end of the polyline
void
Polyline::clip_end(double distance)
{
    while (distance > 0) {
        Point last_point = this->last_point();
        this->points.pop_back();
        if (this->points.empty()) break;
        
        double last_segment_length = last_point.distance_to(this->last_point());
        if (last_segment_length <= distance) {
            distance -= last_segment_length;
            continue;
        }
        
        Line segment(last_point, this->last_point());
        this->points.push_back(segment.point_at(distance));
        distance = 0;
    }
}

// removes the given distance from the start of the polyline
void
Polyline::clip_start(double distance)
{
    this->reverse();
    this->clip_end(distance);
    if (this->points.size() >= 2) this->reverse();
}

void
Polyline::extend_end(double distance)
{
    // relocate last point by extending the last segment by the specified length
    Line line(this->points[ this->points.size()-2 ], this->points.back());
    this->points.pop_back();
    this->points.push_back(line.point_at(line.length() + distance));
}

void
Polyline::extend_start(double distance)
{
    // relocate first point by extending the first segment by the specified length
    Line line(this->points[1], this->points.front());
    this->points[0] = line.point_at(line.length() + distance);
}

/* this method returns a collection of points picked on the polygon contour
   so that they are evenly spaced according to the input distance */
void
Polyline::equally_spaced_points(double distance, Points* points) const
{
    points->push_back(this->first_point());
    double len = 0;
    
    for (Points::const_iterator it = this->points.begin() + 1; it != this->points.end(); ++it) {
        double segment_length = it->distance_to(*(it-1));
        len += segment_length;
        if (len < distance) continue;
        
        if (len == distance) {
            points->push_back(*it);
            len = 0;
            continue;
        }
        
        double take = segment_length - (len - distance);  // how much we take of this segment
        Line segment(*(it-1), *it);
        points->push_back(segment.point_at(take));
        it--;
        len = -take;
    }
}

void
Polyline::simplify(double tolerance)
{
    this->points = MultiPoint::_douglas_peucker(this->points, tolerance);
}

void
Polyline::split_at(const Point &point, Polyline* p1, Polyline* p2) const
{
    if (this->points.empty()) return;
    
    // find the line to split at
    size_t line_idx = 0;
    Point p = this->first_point();
    double min = point.distance_to(p);
    Lines lines = this->lines();
    for (Lines::const_iterator line = lines.begin(); line != lines.end(); ++line) {
        Point p_tmp = point.projection_onto(*line);
        if (point.distance_to(p_tmp) < min) {
	        p = p_tmp;
	        min = point.distance_to(p);
	        line_idx = line - lines.begin();
        }
    }
    
    // create first half
    p1->points.clear();
    for (Lines::const_iterator line = lines.begin(); line != lines.begin() + line_idx + 1; ++line) {
        if (!line->a.coincides_with(p)) p1->points.push_back(line->a);
    }
    // we add point instead of p because they might differ because of numerical issues
    // and caller might want to rely on point belonging to result polylines
    p1->points.push_back(point);
    
    // create second half
    p2->points.clear();
    p2->points.push_back(point);
    for (Lines::const_iterator line = lines.begin() + line_idx; line != lines.end(); ++line) {
        if (!line->b.coincides_with(p)) p2->points.push_back(line->b);
    }
}


#ifdef SLIC3RXS
REGISTER_CLASS(Polyline, "Polyline");

void
Polyline::from_SV_check(SV* poly_sv)
{
    if (!sv_isa(poly_sv, perl_class_name(this)) && !sv_isa(poly_sv, perl_class_name_ref(this)))
        CONFESS("Not a valid %s object",perl_class_name(this));
    
    MultiPoint::from_SV_check(poly_sv);
}
#endif

}
