## [0.8.1] - 2015-08-01

  * Added support for a GPX `desc` tag. (@doc75)

## [0.8] - 2015-05-14

### Introduced changes from andrewhao/gpx fork:

  * Fix Rakefiles and move to use Nokigiri (Guillaume Dott)
  * Fix compatibility with 1.0 GPX schemas (Douglas Robertson)
  * Added Ruby 2.2 compatibility and GPX track smoothing capabilities
    (@kbb29)
  * Adding time to waypoints, restore xmlns:nsi attribute (@merlos)
  * Refactor distance calculation methods to the TrackPoint (Andrew Hao)
  * Adding Travis, Code Climate badges.

## [0.7] - 2015-05-09

  * @rb2k: Make tests and code ruby 1.9 compatible (#3)
    * Switch XML parsing library to hpricot from libxml
  * @ustas-v: Fix bug #2160. Invalid elevation segment. (#4)
  * Doug Fales explicitly released this library under MIT license.
  * Updated changelog and fixing some indentation in waypoint.rb.

## [0.6] - 2010-02-27

	* Putting the gem building stuff into a gemspec.
	* Fixing some tests since git does not believe in empty directories.
	* Fixing README formatting.
	* README edits.
	* More rdoc tweaks.
	* Changing README to rdoc ext for github.
	* Adding the ability to write GPX to a string in addition to a file.  Thanks to Douglas Robertson for the patch.
	* Adding a patch from Douglas Robertson that allows using version 1.0 of the schema for output.

## [0.5] - 2009-07-07

	* Adding changelog.
	* Revving to version 0.5.
	* Changing my contact email address.
	* Patches from Tom Verbeure (mtbguru.com) to work with libxml-ruby 1.x.
	* Patch from Kang-min Liu to support speed element.

## [0.4] - 2008-02-19

	* Revving to 0.4.
	* Adding some new unit tests and fixing several file export bugs reported by Jochen Topf. New unit tests also uncovered a bug where the number of trackpoints reported in a file was twice the actual number.

## [0.3] - 2008-02-11

	* Going to version 0.3.
	* Updating unit tests in light of recent fixes to routes and waypoints code.
	* Thanks to Mike Gauland for discovering some route- and waypoint-related bugs.  I've fixed them and also added #to_s on Waypoint so it's easier to debug.
	* Thanks to Christian Koerner for finding and fixing these bugs in the waypoint code.
	* Another patch from Gaku Ueda.  This one allows you to pass in a string of GPX data using the :gpx_date => option.  Thanks Gaku!

## [0.2] - 2007-11-30

	* Updating the version #.
	* Updates courtesy of Gaku Ueda:
    * Adding support for GPX 1.0 as well as 1.1 (since libxml namespace parsing was hard-coded to 1.1. previously).
    * Adding a GPX 1.0 unit test file.
    * Miscellaneous updates to make it work with Ruby 1.8.6.
	* First stab at using libxml-ruby instead of REXML.  I'm seeing the unit tests finish in under 14 seconds.  That is compared to 2 minutes using REXML. (Doug Fales <doug@falesafeconsulting.com>)
	* Fixing more nil time exceptions. (Doug Fales <doug@falesafeconsulting.com>)
	* Fixing an exception in contains_time?. (Doug Fales <doug@falesafeconsulting.com>)
	* A couple of fixes to make the library comply with the different attribute names possible on the bounds element. (Doug Fales <doug@falesafeconsulting.com>)
	* Fixing nil time bug. (Doug Fales <doug@falesafeconsulting.com>)

## [0.1] - 2006-10-14

* Initial import of gpx gem. (Doug Fales <doug@falesafeconsulting.com>)

[unreleased]: https://github.com/dougfales/gpx/compare/v0.8...HEAD
[0.8]: https://github.com/dougfales/gpx/compare/v0.7...v0.8
[0.7]: https://github.com/dougfales/gpx/compare/v0.6...v0.7
[0.6]: https://github.com/dougfales/gpx/compare/v0.5...v0.6
[0.5]: https://github.com/dougfales/gpx/compare/v0.4...v0.5
[0.4]: https://github.com/dougfales/gpx/compare/v0.3...v0.4
[0.3]: https://github.com/dougfales/gpx/compare/v0.2...v0.3
[0.2]: https://github.com/dougfales/gpx/compare/v0.1...v0.2
[0.1]: https://github.com/dougfales/gpx/commit/371a3fa0b971c9a66c66f941eb4f5c3fa18e424f
