const mongoose = require('mongoose');
const Regime = require('./models/regime');
const KcalTracking = require('./models/kcalTracking');

mongoose.connect(process.env.MONGO_URI_REGIME, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(async () => {
  console.log('Regime MongoDB connected');
  await Regime.deleteMany({});
  await KcalTracking.deleteMany({});

  await Regime.create({
    userId: 'test_user',
    dayIndex: 0,
    meals: [
      {
        titre: "Petit-déjeuner",
        aliments: [
          { nom: "Œufs", kcal: 150, checked: false },
          { nom: "Pain complet", kcal: 120, checked: false },
          { nom: "Orange", kcal: 80, checked: false },
        ]
      },
      {
        titre: "Déjeuner",
        aliments: [
          { nom: "Poulet", kcal: 250, checked: false },
          { nom: "Riz", kcal: 200, checked: false },
          { nom: "Légumes", kcal: 100, checked: false },
        ]
      },
      {
        titre: "Dîner",
        aliments: [
          { nom: "Soupe", kcal: 120, checked: false },
          { nom: "Yaourt", kcal: 90, checked: false },
          { nom: "Pomme", kcal: 60, checked: false },
        ]
      },
    ]
  });
  // Add more days (1-6) as needed

  await KcalTracking.create({
    userId: 'test_user',
    kcalPrescrit: [1450, 1300, 1550, 1600, 1500, 1700, 1400],
    kcalMange: [1200, 1100, 1400, 1300, 1350, 1600, 1200]
  });

  console.log('Data seeded');
  mongoose.connection.close();
}).catch(err => console.error(err));