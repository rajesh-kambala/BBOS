namespace BBOSMobile.Core.Interfaces
{
	using System;
	using System.Threading;
	using System.Threading.Tasks;

	/// <summary>
	///     Interface IGeolocator
	/// </summary>
	public interface IGeolocator
	{
		/// <summary>
		///     Gets or sets the desired accuracy.
		/// </summary>
		/// <value>The desired accuracy.</value>
		double DesiredAccuracy { get; set; }

		/// <summary>
		///     Gets a value indicating whether this instance is listening.
		/// </summary>
		/// <value><c>true</c> if this instance is listening; otherwise, <c>false</c>.</value>
		bool IsListening { get; }

		/// <summary>
		///     Gets a value indicating whether [supports heading].
		/// </summary>
		/// <value><c>true</c> if [supports heading]; otherwise, <c>false</c>.</value>
		bool SupportsHeading { get; }

		/// <summary>
		///     Gets a value indicating whether this instance is geolocation available.
		/// </summary>
		/// <value><c>true</c> if this instance is geolocation available; otherwise, <c>false</c>.</value>
		bool IsGeolocationAvailable { get; }

		/// <summary>
		///     Gets a value indicating whether this instance is geolocation enabled.
		/// </summary>
		/// <value><c>true</c> if this instance is geolocation enabled; otherwise, <c>false</c>.</value>
		bool IsGeolocationEnabled { get; }

		/// <summary>
		///     Occurs when [position error].
		/// </summary>
		event EventHandler<PositionErrorEventArgs> PositionError;

		/// <summary>
		///     Occurs when [position changed].
		/// </summary>
		event EventHandler<PositionEventArgs> PositionChanged;

		/// <summary>
		///     Gets the position asynchronous.
		/// </summary>
		/// <param name="timeout">The timeout.</param>
		/// <returns>Task&lt;Position&gt;.</returns>
		Task<Position> GetPositionAsync(int timeout);

		/// <summary>
		///     Gets the position asynchronous.
		/// </summary>
		/// <param name="timeout">The timeout.</param>
		/// <param name="includeHeading">if set to <c>true</c> [include heading].</param>
		/// <returns>Task&lt;Position&gt;.</returns>
		Task<Position> GetPositionAsync(int timeout, bool includeHeading);

		/// <summary>
		///     Gets the position asynchronous.
		/// </summary>
		/// <param name="cancelToken">The cancel token.</param>
		/// <returns>Task&lt;Position&gt;.</returns>
		Task<Position> GetPositionAsync(CancellationToken cancelToken);

		/// <summary>
		///     Gets the position asynchronous.
		/// </summary>
		/// <param name="cancelToken">The cancel token.</param>
		/// <param name="includeHeading">if set to <c>true</c> [include heading].</param>
		/// <returns>Task&lt;Position&gt;.</returns>
		Task<Position> GetPositionAsync(CancellationToken cancelToken, bool includeHeading);

		/// <summary>
		///     Gets the position asynchronous.
		/// </summary>
		/// <param name="timeout">The timeout.</param>
		/// <param name="cancelToken">The cancel token.</param>
		/// <returns>Task&lt;Position&gt;.</returns>
		Task<Position> GetPositionAsync(int timeout, CancellationToken cancelToken);

		/// <summary>
		///     Gets the position asynchronous.
		/// </summary>
		/// <param name="timeout">The timeout.</param>
		/// <param name="cancelToken">The cancel token.</param>
		/// <param name="includeHeading">if set to <c>true</c> [include heading].</param>
		/// <returns>Task&lt;Position&gt;.</returns>
		Task<Position> GetPositionAsync(int timeout, CancellationToken cancelToken, bool includeHeading);

		/// <summary>
		///     Start listening to location changes
		/// </summary>
		/// <param name="minTime">Minimum interval in milliseconds</param>
		/// <param name="minDistance">Minimum distance in meters</param>
		void StartListening(uint minTime, double minDistance);

		/// <summary>
		///     Start listening to location changes
		/// </summary>
		/// <param name="minTime">Minimum interval in milliseconds</param>
		/// <param name="minDistance">Minimum distance in meters</param>
		/// <param name="includeHeading">Include heading information</param>
		void StartListening(uint minTime, double minDistance, bool includeHeading);

		/// <summary>
		///     Stop listening to location changes
		/// </summary>
		void StopListening();
	}

	/// <summary>
	/// Class Position.
	/// </summary>
	public class Position
	{
		/// <summary>
		/// Initializes a new instance of the <see cref="Position" /> class.
		/// </summary>
		public Position()
		{
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="Position" /> class.
		/// </summary>
		/// <param name="position">The position.</param>
		/// <exception cref="System.ArgumentNullException">position</exception>
		public Position(Position position)
		{
			if (position == null)
			{
				throw new ArgumentNullException("position");
			}

			Timestamp = position.Timestamp;
			Latitude = position.Latitude;
			Longitude = position.Longitude;
			Altitude = position.Altitude;
			AltitudeAccuracy = position.AltitudeAccuracy;
			Accuracy = position.Accuracy;
			Heading = position.Heading;
			Speed = position.Speed;
		}

		/// <summary>
		/// Gets or sets the timestamp.
		/// </summary>
		/// <value>The timestamp.</value>
		public DateTimeOffset Timestamp { get; set; }

		/// <summary>
		/// Gets or sets the latitude.
		/// </summary>
		/// <value>The latitude.</value>
		public double Latitude { get; set; }

		/// <summary>
		/// Gets or sets the longitude.
		/// </summary>
		/// <value>The longitude.</value>
		public double Longitude { get; set; }

		/// <summary>
		/// Gets or sets the altitude in meters relative to sea level.
		/// </summary>
		/// <value>The altitude.</value>
		public double? Altitude { get; set; }

		/// <summary>
		/// Gets or sets the potential position error radius in meters.
		/// </summary>
		/// <value>The accuracy.</value>
		public double? Accuracy { get; set; }

		/// <summary>
		/// Gets or sets the potential altitude error range in meters.
		/// </summary>
		/// <value>The altitude accuracy.</value>
		/// <remarks>Not supported on Android, will always read 0.</remarks>
		public double? AltitudeAccuracy { get; set; }

		/// <summary>
		/// Gets or sets the heading in degrees relative to true North.
		/// </summary>
		/// <value>The heading.</value>
		public double? Heading { get; set; }

		/// <summary>
		/// Gets or sets the speed in meters per second.
		/// </summary>
		/// <value>The speed.</value>
		public double? Speed { get; set; }
	}

	/// <summary>
	/// Class PositionEventArgs.
	/// </summary>
	public class PositionEventArgs : EventArgs
	{
		/// <summary>
		/// Initializes a new instance of the <see cref="PositionEventArgs"/> class.
		/// </summary>
		/// <param name="position">The position.</param>
		/// <exception cref="System.ArgumentNullException">position</exception>
		public PositionEventArgs(Position position)
		{
			if (position == null)
			{
				throw new ArgumentNullException("position");
			}

			Position = position;
		}

		/// <summary>
		/// Gets the position.
		/// </summary>
		/// <value>The position.</value>
		public Position Position { get; private set; }
	}

	/// <summary>
	/// Class GeolocationException.
	/// </summary>
	public class GeolocationException : Exception
	{
		/// <summary>
		/// Initializes a new instance of the <see cref="GeolocationException"/> class.
		/// </summary>
		/// <param name="error">The error.</param>
		/// <exception cref="System.ArgumentException">error is not a valid GelocationError member;error</exception>
		public GeolocationException(GeolocationError error)
			: base("A geolocation error occured: " + error)
		{
			if (!Enum.IsDefined(typeof(GeolocationError), error))
			{
				throw new ArgumentException("error is not a valid GelocationError member", "error");
			}

			Error = error;
		}

		/// <summary>
		/// Initializes a new instance of the <see cref="GeolocationException"/> class.
		/// </summary>
		/// <param name="error">The error.</param>
		/// <param name="innerException">The inner exception.</param>
		/// <exception cref="System.ArgumentException">error is not a valid GelocationError member;error</exception>
		public GeolocationException(GeolocationError error, Exception innerException)
			: base("A geolocation error occured: " + error, innerException)
		{
			if (!Enum.IsDefined(typeof(GeolocationError), error))
			{
				throw new ArgumentException("error is not a valid GelocationError member", "error");
			}

			Error = error;
		}

		/// <summary>
		/// Gets the error.
		/// </summary>
		/// <value>The error.</value>
		public GeolocationError Error { get; private set; }
	}

	/// <summary>
	/// Class PositionErrorEventArgs.
	/// </summary>
	public class PositionErrorEventArgs : EventArgs
	{
		/// <summary>
		/// Initializes a new instance of the <see cref="PositionErrorEventArgs"/> class.
		/// </summary>
		/// <param name="error">The error.</param>
		public PositionErrorEventArgs(GeolocationError error)
		{
			Error = error;
		}

		/// <summary>
		/// Gets the error.
		/// </summary>
		/// <value>The error.</value>
		public GeolocationError Error { get; private set; }
	}

	/// <summary>
	/// Enum GeolocationError
	/// </summary>
	public enum GeolocationError
	{
		/// <summary>
		/// The provider was unable to retrieve any position data.
		/// </summary>
		PositionUnavailable,

		/// <summary>
		/// The app is not, or no longer, authorized to receive location data.
		/// </summary>
		Unauthorized
	}

	/// <summary>
	/// Position extensions
	/// </summary>
	public static class PositionExtensions
	{
		/// <summary>
		/// The equator radius.
		/// </summary>
		public const int EquatorRadius = 6378137;

		/// <summary>
		/// Calculates distance between two locations.
		/// </summary>
		/// <param name="a">Location a</param>
		/// <param name="b">Location b</param>
		/// <returns>The <see cref="System.Double" />The distance in meters</returns>
		public static double DistanceFrom(this Position a, Position b)
		{
			/*
			double distance = Math.Acos(
				(Math.Sin(a.Latitude) * Math.Sin(b.Latitude)) +
				(Math.Cos(a.Latitude) * Math.Cos(b.Latitude))
				* Math.Cos(b.Longitude - a.Longitude));
			 * */

			var dLat = b.Latitude.DegreesToRadians() - a.Latitude.DegreesToRadians();
			var dLon = b.Longitude.DegreesToRadians() - a.Longitude.DegreesToRadians();

			var a1 = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) + Math.Cos(a.Latitude.DegreesToRadians()) * Math.Cos(b.Latitude.DegreesToRadians()) * Math.Sin(dLon / 2) * Math.Sin(dLon / 2);
			var distance = 2 * Math.Atan2(Math.Sqrt(a1), Math.Sqrt(1 - a1));

			return EquatorRadius * distance;
		}

		/// <summary>
		/// Calculates bearing between start and stop.
		/// </summary>
		/// <param name="start">Start coordinates.</param>
		/// <param name="stop">Stop coordinates.</param>
		/// <returns>The <see cref="System.Double" />.</returns>
		public static double BearingFrom(this Position start, Position stop)
		{
			var deltaLon = stop.Longitude - start.Longitude;
			var cosStop = Math.Cos(stop.Latitude);
			return Math.Atan2(
				(Math.Cos(start.Latitude) * Math.Sin(stop.Latitude)) -
				(Math.Sin(start.Latitude) * cosStop * Math.Cos(deltaLon)),
				Math.Sin(deltaLon) * cosStop);
		}

		/// <summary>
		/// Radianses to degrees.
		/// </summary>
		/// <param name="rad">The RAD.</param>
		/// <returns>System.Double.</returns>
		public static double RadiansToDegrees(this double rad)
		{
			return 180.0 * rad / Math.PI;
		}

		/// <summary>
		/// Degreeses to radians.
		/// </summary>
		/// <param name="deg">The deg.</param>
		/// <returns>System.Double.</returns>
		public static double DegreesToRadians(this double deg)
		{
			return Math.PI * deg / 180.0;
		}
	}
}
