/// The tag a poster flies into its details screen on.
///
/// A Hero tag has to be unique within the route it is drawn in, and a title is
/// not: TMDB's popular and top-rated lists overlap, so the same film or series
/// is on the same tab twice. Worse, `AutoTabsRouter.pageView` keeps all three
/// tabs mounted inside the one wrapper route, so a duplicate anywhere in any
/// of them breaks every flight on the screen rather than only its own — which
/// is why touching the series tab once used to stop the films tab animating.
///
/// So the tag is where the poster is rather than what it is: [scope] names the
/// row and the screen, and within a row the id tells the cards apart. [index]
/// stands in for a title the API sent without one — prefixed, so a missing id
/// at position 5 cannot land on the same tag as id 5.
///
/// It only has to be unique at the moment the flight starts: the tag travels
/// to the details screen as a route argument, so nothing recomputes it there.
String posterHeroTag(String scope, {required int index, int? id}) =>
    'poster-$scope-${id == null ? 'index$index' : 'id$id'}';
