import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

const OPENWEATHER_API_KEY = process.env.OPENWEATHER_API_KEY;

/**
 * Service pour récupérer les données météo réelles depuis OpenWeather API
 */
export class WeatherService {
  /**
   * Récupère la météo actuelle pour une localisation
   * @param {number} latitude 
   * @param {number} longitude 
   * @returns {Promise<Object>}
   */
  static async getCurrentWeather(latitude, longitude) {
    if (!OPENWEATHER_API_KEY || OPENWEATHER_API_KEY === 'your_openweather_api_key_here') {
      throw new Error('OPENWEATHER_API_KEY n\'est pas configurée. Veuillez l\'ajouter dans le fichier .env');
    }

    try {
      const response = await axios.get('https://api.openweathermap.org/data/2.5/weather', {
        params: {
          lat: latitude,
          lon: longitude,
          appid: OPENWEATHER_API_KEY,
          units: 'metric',
          lang: 'fr'
        }
      });

      const data = response.data;
      
      return {
        location: data.name || `${latitude},${longitude}`,
        latitude: data.coord.lat,
        longitude: data.coord.lon,
        temperature: data.main.temp,
        humidity: data.main.humidity,
        pressure: data.main.pressure,
        windSpeed: data.wind?.speed ? data.wind.speed * 3.6 : 0, // Convertir m/s en km/h
        windDirection: data.wind?.deg || 0,
        condition: data.weather[0]?.main || 'Clear',
        description: data.weather[0]?.description || '',
        visibility: data.visibility ? data.visibility / 1000 : 10, // Convertir en km
        uvIndex: 0, // OpenWeather free tier ne fournit pas l'UV index
        rainfall: data.rain?.['1h'] || 0,
        timestamp: new Date().toISOString(),
        forecast: {}
      };
    } catch (error) {
      console.error('Erreur OpenWeather API:', error.response?.data || error.message);
      throw new Error(`Impossible de récupérer les données météo: ${error.message}`);
    }
  }

  /**
   * Récupère les prévisions météo pour 5 jours
   * @param {number} latitude 
   * @param {number} longitude 
   * @returns {Promise<Array>}
   */
  static async getForecast(latitude, longitude, days = 5) {
    if (!OPENWEATHER_API_KEY || OPENWEATHER_API_KEY === 'your_openweather_api_key_here') {
      throw new Error('OPENWEATHER_API_KEY n\'est pas configurée. Veuillez l\'ajouter dans le fichier .env');
    }

    try {
      const response = await axios.get('https://api.openweathermap.org/data/2.5/forecast', {
        params: {
          lat: latitude,
          lon: longitude,
          appid: OPENWEATHER_API_KEY,
          units: 'metric',
          lang: 'fr',
          cnt: days * 8 // 8 prévisions par jour (toutes les 3 heures)
        }
      });

      const forecasts = [];
      const processedDates = new Set();

      for (const item of response.data.list) {
        const date = new Date(item.dt * 1000).toISOString().split('T')[0];
        
        // Ne prendre qu'une prévision par jour (midi)
        if (!processedDates.has(date) && item.dt_txt.includes('12:00')) {
          processedDates.add(date);
          forecasts.push({
            location: response.data.city.name,
            date: date,
            minTemperature: item.main.temp_min,
            maxTemperature: item.main.temp_max,
            humidity: item.main.humidity,
            windSpeed: item.wind?.speed ? item.wind.speed * 3.6 : 0,
            condition: item.weather[0]?.main || 'Clear',
            description: item.weather[0]?.description || '',
            rainfall: item.rain?.['3h'] || 0,
            uvIndex: 0
          });
        }
      }

      return forecasts.slice(0, days);
    } catch (error) {
      console.error('Erreur OpenWeather Forecast API:', error.response?.data || error.message);
      throw new Error(`Impossible de récupérer les prévisions: ${error.message}`);
    }
  }

  /**
   * Génère des recommandations agricoles basées sur les données météo
   * @param {Object} weatherData 
   * @returns {Array<string>}
   */
  static getAgriculturalRecommendations(weatherData) {
    const recommendations = [];

    if (weatherData.temperature > 35) {
      recommendations.push('Température élevée: Augmenter l\'irrigation et fournir de l\'ombrage aux cultures sensibles');
    }

    if (weatherData.temperature < 15) {
      recommendations.push('Température basse: Protéger les cultures sensibles au froid');
    }

    if (weatherData.humidity < 40) {
      recommendations.push('Humidité faible: Irrigation recommandée pour maintenir l\'humidité du sol');
    }

    if (weatherData.rainfall > 20) {
      recommendations.push('Pluies abondantes: Vérifier le drainage des champs et protéger les cultures sensibles');
    }

    if (weatherData.windSpeed > 30) {
      recommendations.push('Vents forts: Protéger les cultures et les équipements');
    }

    if (weatherData.rainfall === 0 && weatherData.humidity < 50) {
      recommendations.push('Conditions sèches: Planifier l\'irrigation d\'urgence');
    }

    return recommendations.length > 0 ? recommendations : ['Conditions météorologiques favorables pour les activités agricoles'];
  }
}

