import CoreLocation
import UIKit

class WeatherViewController: UIViewController {
  @IBOutlet var conditionImageView: UIImageView!
  @IBOutlet var temperatureLabel: UILabel!
  @IBOutlet var cityLabel: UILabel!
  @IBOutlet var searchTextField: UITextField!

  var weatherManager = WeatherManager()
  let locationManager = CLLocationManager()

  override func viewDidLoad() {
    super.viewDidLoad()

    locationManager.delegate = self

    locationManager.requestWhenInUseAuthorization()
    locationManager.requestLocation()

    searchTextField.delegate = self
    weatherManager.delegate = self
  }

  @IBAction func currentLocationPressed(_ sender: UIButton) {
    locationManager.requestLocation()
  }
}

// MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
  @IBAction func searchPressed(_ sender: UIButton) {
    searchTextField.endEditing(true)
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.endEditing(true)
    return true
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    let city = textField.text

    if let city = city {
      weatherManager.fetchWeather(city: city)
    }

    textField.text = ""
  }

  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    if textField.text != "" {
      return true
    }

    textField.placeholder = "Type something"
    return false
  }
}

// MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
  func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModal) {
    DispatchQueue.main.async {
      self.conditionImageView.image = UIImage(systemName: weather.conditionName)
      self.temperatureLabel.text = weather.tempratureString
      self.cityLabel.text = weather.cityName
    }
  }

  func didFailWithError(error: Error) {
    print(error)
  }
}

// MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }

    locationManager.stopUpdatingLocation()

    let latitude = location.coordinate.latitude
    let longitude = location.coordinate.longitude

    weatherManager.fetchWeather(latitude: latitude, longitude: longitude)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}
