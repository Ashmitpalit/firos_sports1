// lib/utils/constants.dart

class Constants {
  // Firebase Realtime Database URL
  static const String baseUrl = 'https://sportsone-6c433-default-rtdb.firebaseio.com/';

  // Cities and Localities
  static const Map<String, List<String>> cties = {
    // India
    'Delhi': ['Rohini', 'Dwarka', 'Saket', 'Connaught Place', 'Nehru Place', 'Vasant Kunj', 'Greater Kailash'],
    'Mumbai': ['Bandra', 'Andheri', 'Colaba', 'Juhu', 'Worli', 'Malad', 'Borivali'],
    'Bangalore': ['Koramangala', 'Indiranagar', 'Whitefield', 'Jayanagar', 'Malleshwaram', 'HSR Layout', 'Marathahalli'],
    'Kolkata': ['Salt Lake', 'Park Street', 'Howrah', 'Dum Dum', 'New Town', 'Ballygunge', 'Garia'],
    'Chennai': ['T. Nagar', 'Anna Nagar', 'Velachery', 'Adyar', 'Mylapore', 'Besant Nagar', 'Nungambakkam'],
    'Hyderabad': ['Banjara Hills', 'Jubilee Hills', 'Gachibowli', 'Hitech City', 'Kondapur', 'Madhapur', 'Secunderabad'],
    'Ahmedabad': ['Vastrapur', 'Navrangpura', 'Maninagar', 'Satellite', 'Bopal', 'Prahlad Nagar', 'Gurukul'],
    'Pune': ['Koregaon Park', 'Kothrud', 'Viman Nagar', 'Hadapsar', 'Aundh', 'Baner', 'Hinjewadi'],
    'Jaipur': ['C-Scheme', 'Malviya Nagar', 'Vaishali Nagar', 'Tonk Road', 'Mansarovar', 'Raja Park', 'Shyam Nagar'],
    'Lucknow': ['Gomti Nagar', 'Hazratganj', 'Aliganj', 'Indira Nagar', 'Mahanagar', 'Vikas Nagar', 'Jankipuram'],
    // USA
    'New York': ['Manhattan', 'Brooklyn', 'Queens', 'Bronx', 'Staten Island', 'Harlem', 'Chelsea'],
    'Los Angeles': ['Hollywood', 'Santa Monica', 'Downtown LA', 'Beverly Hills', 'Venice', 'Westwood', 'Koreatown'],
    'Chicago': ['Loop', 'Lincoln Park', 'Wicker Park', 'Hyde Park', 'Lakeview', 'River North', 'Logan Square'],
    'Houston': ['Downtown', 'Montrose', 'The Heights', 'Galleria', 'Midtown', 'Westchase', 'River Oaks'],
    'Phoenix': ['Downtown Phoenix', 'Scottsdale', 'Tempe', 'Mesa', 'Chandler', 'Glendale', 'Arcadia'],
    'Philadelphia': ['Center City', 'Old City', 'Fishtown', 'Rittenhouse Square', 'Manayunk', 'South Philly', 'University City'],
    'San Antonio': ['Downtown', 'Alamo Heights', 'Southtown', 'Stone Oak', 'The Pearl', 'Northwest Side', 'Medical Center'],
    'San Diego': ['Gaslamp Quarter', 'La Jolla', 'Hillcrest', 'North Park', 'Ocean Beach', 'Point Loma', 'Mission Valley'],
    'Dallas': ['Downtown Dallas', 'Uptown', 'Deep Ellum', 'Oak Lawn', 'Bishop Arts', 'Preston Hollow', 'Lake Highlands'],
    'San Jose': ['Downtown San Jose', 'Willow Glen', 'Campbell', 'Almaden Valley', 'Rose Garden', 'Santana Row', 'Japantown'],
  };

  // Sports list for autocomplete
  static const List<String> sports = [
    'Food and Beverage',
    'Drinks and Juice',
    'Snacks',
    'Lunch',
    'Dinner',
    'Breakfast',
  
  ];
  static const Map<String, String> sportIons = {
    'Food and Beverage': 'assets/images/sport_icons/cricket.png',
    'Drinks and Juice': 'assets/images/sport_icons/football.png',
    'Snacks': 'assets/images/sport_icons/basketball.png',
    'Lunch': 'assets/images/sport_icons/tennis.png',
    'Dinner': 'assets/images/sport_icons/tennis.png',
    'Breakfast': 'assets/images/sport_icons/tennis.png',


  };

  static const List<String> ageRanges = ['Under 18', '18-30', '30-45', '45+'];
  static const List<String> paidStatuses = ['Paid', 'Unpaid'];

}
