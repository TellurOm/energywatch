/**
 * EnergyWatch - Pure Vanilla JavaScript Application Logic
 * Replicates the full Flutter feature set:
 * - Live Simulated Meter with Drift & Speed Controls
 * - Reactive State Management
 * - SVG Smooth Bezier Charts & 24h Bar Profiles
 * - Interactive Runtime Simulator Sliders
 * - Tariff Engine (Flat Rate & Progressive Tiered Slab)
 * - Habit Adoption Tracking & CO2 Reduction Models
 */

(function () {
  'use strict';

  // --- Core Mock Data ---
  const DEFAULT_STATE = {
    user: 'Amitabh',
    currentPowerKw: 1.84,
    lastUpdated: new Date(),
    simulationSpeed: 'normal', // 'normal' (6s), 'fast' (2s), 'paused'
    activeTab: 'dashboard',
    theme: localStorage.getItem('ew_theme') || 'light',
    selectedFilter: '7D', // 'today', '7D', '30D', '90D', 'custom'

    // Billing Configuration
    billing: {
      ratePerKwh: 8.00,
      fixedCharge: 100.00,
      taxPercent: 0.0,
      isSlabBilling: false,
    },

    // Slabs
    slabTiers: [
      { min: 0, max: 100, rate: 4.50, label: '0–100 units' },
      { min: 100, max: 200, rate: 6.00, label: '101–200 units' },
      { min: 200, max: 300, rate: 8.00, label: '201–300 units' },
      { min: 300, max: Infinity, rate: 10.00, label: '300+ units' },
    ],

    // 30 Days of Historical Daily Data (sums up to 184.5 kWh)
    dailyReadings: [
      5.9, 6.1, 6.3, 5.7, 6.4, 6.8, 6.2,
      5.5, 6.0, 6.2, 5.8, 6.5, 6.9, 6.1,
      5.6, 6.3, 6.7, 5.9, 6.2, 7.0, 6.4,
      7.10, // Yesterday (7.10)
      5.4, 5.9,
      5.8, 6.2, 7.1, 6.5, 8.0, 7.4, 6.72 // Last 7 days ending with today's 6.72
    ],

    // Today's Detailed Hourly Checkpoints
    hourlyReadings: [
      { hour: 0, label: '12 AM', kwh: 0.35, kw: 0.42, isPeak: false },
      { hour: 2, label: '02 AM', kwh: 0.29, kw: 0.36, isPeak: false },
      { hour: 4, label: '04 AM', kwh: 0.24, kw: 0.32, isPeak: false },
      { hour: 6, label: '06 AM', kwh: 0.48, kw: 0.65, isPeak: false },
      { hour: 8, label: '08 AM', kwh: 0.82, kw: 1.25, isPeak: false },
      { hour: 10, label: '10 AM', kwh: 1.10, kw: 1.48, isPeak: false },
      { hour: 12, label: '12 PM', kwh: 1.46, kw: 1.82, isPeak: false },
      { hour: 14, label: '02 PM', kwh: 1.02, kw: 1.35, isPeak: false },
      { hour: 16, label: '04 PM', kwh: 0.88, kw: 1.15, isPeak: false },
      { hour: 18, label: '06 PM', kwh: 1.44, kw: 2.10, isPeak: true },
      { hour: 20, label: '08 PM', kwh: 1.51, kw: 2.25, isPeak: true },
      { hour: 22, label: '10 PM', kwh: 0.94, kw: 1.30, isPeak: true }
    ],

    // 10 Household Appliances
    appliances: [
      {
        id: 'app_ac',
        name: 'Air Conditioner',
        icon: 'ac_unit',
        powerKw: 1.50,
        dailyHours: 5.2,
        monthlyKwh: 72.4,
        isActive: true,
        category: 'Cooling',
        percentage: 39.0,
        cost: 579.0,
        weeklyKwh: [5.1, 4.8, 6.2, 5.5, 7.1, 6.0, 5.2],
        efficiencyScore: 72,
        recommendation: 'Your AC accounts for 39% of household consumption. Increasing the thermostat by 1–2°C and cleaning filters monthly may save up to ₹96/month.'
      },
      {
        id: 'app_water_heater',
        name: 'Water Heater',
        icon: 'water_drop',
        powerKw: 2.00,
        dailyHours: 0.65,
        monthlyKwh: 38.7,
        isActive: false,
        category: 'Heating',
        percentage: 21.0,
        cost: 310.0,
        weeklyKwh: [2.8, 2.7, 3.1, 2.9, 3.5, 3.2, 2.8],
        efficiencyScore: 68,
        recommendation: 'Water heating is your 2nd largest consumer. Reduce geyser runtime to 15 minutes before baths and lower thermostat from 65°C to 50°C.'
      },
      {
        id: 'app_refrigerator',
        name: 'Refrigerator',
        icon: 'kitchen',
        powerKw: 0.18,
        dailyHours: 24.0,
        monthlyKwh: 25.8,
        isActive: true,
        category: 'Kitchen',
        percentage: 14.0,
        cost: 206.0,
        weeklyKwh: [1.8, 1.9, 1.8, 1.9, 1.9, 1.8, 1.8],
        efficiencyScore: 85,
        recommendation: 'Ensure adequate 10cm rear ventilation behind condenser coils and avoid keeping warm leftovers inside to maintain optimal efficiency.'
      },
      {
        id: 'app_washing_machine',
        name: 'Washing Machine',
        icon: 'local_laundry_service',
        powerKw: 0.85,
        dailyHours: 0.50,
        monthlyKwh: 12.9,
        isActive: false,
        category: 'Laundry',
        percentage: 7.0,
        cost: 103.0,
        weeklyKwh: [0.9, 0.0, 1.0, 0.0, 1.2, 1.8, 0.9],
        efficiencyScore: 78,
        recommendation: 'Run washing cycles with full capacity and choose 30°C eco-wash modes rather than hot water cycles to save energy.'
      },
      {
        id: 'app_television',
        name: 'Smart Television',
        icon: 'tv',
        powerKw: 0.12,
        dailyHours: 4.5,
        monthlyKwh: 9.2,
        isActive: true,
        category: 'Entertainment',
        percentage: 5.0,
        cost: 74.0,
        weeklyKwh: [0.7, 0.6, 0.8, 0.6, 0.9, 0.9, 0.7],
        efficiencyScore: 80,
        recommendation: 'Disable instant-on standby mode and enable automatic ambient light sensor dimming to prevent excessive backlight draw.'
      },
      {
        id: 'app_desktop',
        name: 'Desktop Computer',
        icon: 'computer',
        powerKw: 0.22,
        dailyHours: 4.0,
        monthlyKwh: 7.4,
        isActive: true,
        category: 'Work/Study',
        percentage: 4.0,
        cost: 59.0,
        weeklyKwh: [0.6, 0.6, 0.6, 0.6, 0.7, 0.4, 0.5],
        efficiencyScore: 76,
        recommendation: 'Configure display sleep after 5 minutes and system sleep after 15 minutes of inactivity to cut idle workstation drain.'
      },
      {
        id: 'app_fans',
        name: 'Ceiling Fans (3x)',
        icon: 'mode_fan',
        powerKw: 0.09,
        dailyHours: 14.0,
        monthlyKwh: 7.4,
        isActive: true,
        category: 'Cooling',
        percentage: 4.0,
        cost: 59.0,
        weeklyKwh: [0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6],
        efficiencyScore: 92,
        recommendation: 'Fans cool occupants through evaporative airflow, not room air temperature. Switch off fans when vacating rooms.'
      },
      {
        id: 'app_lights',
        name: 'LED Smart Lighting',
        icon: 'lightbulb',
        powerKw: 0.11,
        dailyHours: 5.0,
        monthlyKwh: 5.5,
        isActive: true,
        category: 'Lighting',
        percentage: 3.0,
        cost: 44.0,
        weeklyKwh: [0.4, 0.4, 0.4, 0.4, 0.5, 0.4, 0.4],
        efficiencyScore: 90,
        recommendation: 'Modern LED fixtures are already highly efficient. Utilize sunset/sunrise automated schedules to avoid accidental daytime use.'
      },
      {
        id: 'app_microwave',
        name: 'Microwave Oven',
        icon: 'microwave',
        powerKw: 1.20,
        dailyHours: 0.15,
        monthlyKwh: 3.7,
        isActive: false,
        category: 'Kitchen',
        percentage: 2.0,
        cost: 30.0,
        weeklyKwh: [0.3, 0.2, 0.3, 0.2, 0.4, 0.3, 0.3],
        efficiencyScore: 75,
        recommendation: 'Use lids to trap steam and speed up heating times. Switch off main outlet when not in use to eliminate 3W display standby load.'
      },
      {
        id: 'app_water_pump',
        name: 'Water Pump',
        icon: 'water',
        powerKw: 0.75,
        dailyHours: 0.16,
        monthlyKwh: 3.5,
        isActive: false,
        category: 'Utility',
        percentage: 2.0,
        cost: 28.0,
        weeklyKwh: [0.3, 0.2, 0.3, 0.3, 0.3, 0.3, 0.3],
        efficiencyScore: 82,
        recommendation: 'Inspect pipeline joints for micro-leaks. Schedule water tank filling in afternoon hours to avoid grid peak surcharge rates.'
      }
    ],

    // 6 Actionable Savings Tips
    savingsTips: [
      {
        id: 'tip_ac',
        title: 'AC Temperature Optimization',
        description: 'Raise AC thermostat by 1–2°C and clean the filters regularly.',
        estimatedSaving: 96.0,
        reductionPercent: 6.5,
        difficulty: 'Medium',
        category: 'Cooling',
        icon: 'thermostat',
        isApplied: false,
        steps: [
          'Set your AC thermostat to 24°C - 26°C instead of 18°C.',
          'Clean the air filter mesh every 2-3 weeks.',
          'Keep curtains drawn during sunny afternoon hours.'
        ]
      },
      {
        id: 'tip_geyser',
        title: 'Water Heater Scheduling',
        description: 'Reduce geyser heating duration and lower thermostat to 50°C.',
        estimatedSaving: 71.0,
        reductionPercent: 4.8,
        difficulty: 'Easy',
        category: 'Heating',
        icon: 'hot_tub',
        isApplied: false,
        steps: [
          'Turn on the water heater only 15 minutes before bathing.',
          'Turn off immediately after use or install a mechanical timer.',
          'Lower water thermostat dial from 65°C to 50°C.'
        ]
      },
      {
        id: 'tip_standby',
        title: 'Eliminate Standby Vampire Load',
        description: 'Switch off TVs, desktop computers, and chargers at the wall switch.',
        estimatedSaving: 42.0,
        reductionPercent: 2.8,
        difficulty: 'Easy',
        category: 'Standby',
        icon: 'power_off',
        isApplied: false,
        steps: [
          'Use a power strip with a master switch for entertainment units.',
          'Unplug phone and laptop chargers when fully charged.',
          'Turn off set-top boxes and gaming consoles when idle.'
        ]
      },
      {
        id: 'tip_lighting',
        title: 'Lighting Upgrade & Scheduling',
        description: 'Ensure 100% LED bulbs and leverage natural daylight during daytime.',
        estimatedSaving: 38.0,
        reductionPercent: 2.5,
        difficulty: 'Easy',
        category: 'Lighting',
        icon: 'lightbulb',
        isApplied: false,
        steps: [
          'Replace any remaining CFL or incandescent bulbs with 9W LEDs.',
          'Keep light fixtures and glass covers clean for maximum lumen output.',
          'Utilize natural window daylight during morning hours.'
        ]
      },
      {
        id: 'tip_fridge',
        title: 'Refrigerator Maintenance',
        description: 'Inspect magnetic door gasket seals and keep cooling dial at 3°C to 4°C.',
        estimatedSaving: 24.0,
        reductionPercent: 1.6,
        difficulty: 'Easy',
        category: 'Kitchen',
        icon: 'kitchen',
        isApplied: false,
        steps: [
          'Test door seal by closing a paper currency note in the door; it should feel snug.',
          'Allow hot foods to cool to room temperature before placing in the fridge.',
          'Keep 10 cm space behind the fridge for coil ventilation.'
        ]
      },
      {
        id: 'tip_peak_shifting',
        title: 'Peak Load Shifting',
        description: 'Run washing machines and water pumps during off-peak morning hours.',
        estimatedSaving: 15.0,
        reductionPercent: 1.0,
        difficulty: 'Medium',
        category: 'Utility',
        icon: 'schedule',
        isApplied: false,
        steps: [
          'Avoid operating high-wattage appliances between 6:00 PM and 10:00 PM.',
          'Run washing machine laundry loads on weekend mornings.',
          'Fill overhead water storage tanks during mid-day.'
        ]
      }
    ]
  };

  // Clone state for runtime
  let state = JSON.parse(JSON.stringify(DEFAULT_STATE));
  state.lastUpdated = new Date();

  // --- Computation Engine ---
  const Computations = {
    getTodayConsumption: () => 6.72,
    getYesterdayConsumption: () => 7.10,
    getTodayChangePercent: () => -5.35,
    getMonthlyConsumption: () => 184.5,
    getPreviousMonthConsumption: () => 201.7,
    getWeeklyConsumption: () => 47.6,
    getPreviousWeekConsumption: () => 51.8,
    getWeeklyChangePercent: () => -8.1,

    calculateBill: (kwh, rate, fixed, taxPercent, isSlab) => {
      const consumption = Math.max(0, parseFloat(kwh) || 0);
      const fixedCharge = Math.max(0, parseFloat(fixed) || 0);
      const taxRate = Math.max(0, parseFloat(taxPercent) || 0);

      if (!isSlab) {
        const ratePerUnit = Math.max(0, parseFloat(rate) || 0);
        const energyCharge = consumption * ratePerUnit;
        const taxCharge = energyCharge * (taxRate / 100);
        const total = energyCharge + fixedCharge + taxCharge;
        return {
          consumption,
          energyCharge,
          fixedCharge,
          taxCharge,
          total,
          isSlab: false,
          slabs: []
        };
      }

      // Slab Calculation
      let remaining = consumption;
      let energyCharge = 0;
      const slabBreakdown = [];

      for (const tier of state.slabTiers) {
        if (remaining <= 0) break;
        const capacity = tier.max - tier.min;
        const unitsInSlab = Math.min(remaining, capacity);
        const cost = unitsInSlab * tier.rate;
        energyCharge += cost;
        remaining -= unitsInSlab;

        slabBreakdown.push({
          label: tier.label,
          units: unitsInSlab,
          rate: tier.rate,
          cost: cost
        });
      }

      const taxCharge = energyCharge * (taxRate / 100);
      const total = energyCharge + fixedCharge + taxCharge;

      return {
        consumption,
        energyCharge,
        fixedCharge,
        taxCharge,
        total,
        isSlab: true,
        slabs: slabBreakdown
      };
    },

    getPotentialMonthlySavings: () => {
      return state.savingsTips.reduce((acc, tip) => {
        // Dynamic formula: Monthly Kwh * reduction % * rate
        const tipSaving = (state.monthlyConsumption || 184.5) * (tip.reductionPercent / 100) * state.billing.ratePerKwh;
        return acc + tipSaving;
      }, 0);
    }
  };

  // --- Formatting Helpers ---
  const Format = {
    currency: (val) => '₹' + Math.round(val).toLocaleString('en-IN'),
    currencyExact: (val) => '₹' + (Number(val).toFixed(2)),
    energy: (val, dec = 2) => Number(val).toFixed(dec) + ' kWh',
    power: (val) => Number(val).toFixed(2) + ' kW',
    time: (date) => {
      const d = new Date(date);
      let hours = d.getHours();
      const mins = d.getMinutes();
      const ampm = hours >= 12 ? 'PM' : 'AM';
      hours = hours % 12;
      hours = hours ? hours : 12;
      return `${hours.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')} ${ampm}`;
    }
  };

  // --- Live Power Drift Simulation ---
  let simulationInterval = null;

  function startSimulation() {
    if (simulationInterval) clearInterval(simulationInterval);
    if (state.simulationSpeed === 'paused') return;

    const delay = state.simulationSpeed === 'fast' ? 2000 : 6000;
    simulationInterval = setInterval(() => {
      // Gentle drift: +/- 0.05 to 0.12 kW
      const delta = (Math.random() * 0.16) - 0.08;
      let newPower = state.currentPowerKw + delta;
      if (newPower < 1.70) newPower = 1.72 + (Math.random() * 0.05);
      if (newPower > 2.15) newPower = 2.10 - (Math.random() * 0.05);

      state.currentPowerKw = parseFloat(newPower.toFixed(2));
      state.lastUpdated = new Date();
      updateLivePowerUI();
    }, delay);
  }

  function updateLivePowerUI() {
    const powerEl = document.getElementById('live-load-val');
    const timeEl = document.getElementById('live-load-time');
    const settingsVal = document.getElementById('settings-live-load');

    if (powerEl) powerEl.textContent = state.currentPowerKw.toFixed(2);
    if (timeEl) timeEl.textContent = `Updated ${Format.time(state.lastUpdated)}`;
    if (settingsVal) {
      settingsVal.textContent = `Current Active Load: ${state.currentPowerKw.toFixed(2)} kW • Status: ${state.simulationSpeed === 'paused' ? 'Paused' : 'Active'}`;
    }
  }

  // --- Theme Toggle ---
  function applyTheme(theme) {
    state.theme = theme;
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('ew_theme', theme);

    const themeIcon = document.getElementById('header-theme-icon');
    const themeText = document.getElementById('header-theme-text');
    if (themeIcon) themeIcon.textContent = theme === 'dark' ? 'light_mode' : 'dark_mode';
    if (themeText) themeText.textContent = theme === 'dark' ? 'Light' : 'Dark';

    // Re-render charts for theme-specific colors
    renderDashboardTrendChart();
    if (state.activeTab === 'consumption') {
      renderConsumptionTrendChart();
      renderHourlyProfileBarChart();
    }
  }

  // --- SVG Chart Renderers ---
  function renderBezierChart(svgId, dataPoints, labels, height = 240) {
    const svg = document.getElementById(svgId);
    if (!svg) return;

    const width = svg.clientWidth || 700;
    const padding = { top: 20, right: 24, bottom: 35, left: 45 };
    const chartWidth = width - padding.left - padding.right;
    const chartHeight = height - padding.top - padding.bottom;

    const maxY = Math.max(...dataPoints) * 1.15;
    const minY = 0;

    const getX = (index) => padding.left + (index / (dataPoints.length - 1)) * chartWidth;
    const getY = (val) => padding.top + chartHeight - ((val - minY) / (maxY - minY)) * chartHeight;

    // Grid lines (3 horizontal)
    let gridLinesHtml = '';
    const steps = 4;
    for (let i = 0; i <= steps; i++) {
      const val = minY + (i / steps) * maxY;
      const y = getY(val);
      gridLinesHtml += `
        <line x1="${padding.left}" y1="${y}" x2="${width - padding.right}" y2="${y}" class="chart-grid-line" />
        <text x="${padding.left - 10}" y="${y + 4}" class="chart-axis-text" text-anchor="end">${Math.round(val)}</text>
      `;
    }

    // Build smooth Bezier path
    let pathD = `M ${getX(0)} ${getY(dataPoints[0])}`;
    for (let i = 0; i < dataPoints.length - 1; i++) {
      const x0 = getX(i);
      const y0 = getY(dataPoints[i]);
      const x1 = getX(i + 1);
      const y1 = getY(dataPoints[i + 1]);
      const cpx1 = x0 + (x1 - x0) * 0.45;
      const cpy1 = y0;
      const cpx2 = x1 - (x1 - x0) * 0.45;
      const cpy2 = y1;
      pathD += ` C ${cpx1} ${cpy1}, ${cpx2} ${cpy2}, ${x1} ${y1}`;
    }

    // Area path
    const areaD = `${pathD} L ${getX(dataPoints.length - 1)} ${padding.top + chartHeight} L ${getX(0)} ${padding.top + chartHeight} Z`;

    // Data points & X labels
    let pointsHtml = '';
    let xLabelsHtml = '';
    const interval = dataPoints.length <= 7 ? 1 : (dataPoints.length <= 14 ? 2 : 5);

    dataPoints.forEach((val, i) => {
      const cx = getX(i);
      const cy = getY(val);

      if (dataPoints.length <= 10) {
        pointsHtml += `
          <circle cx="${cx}" cy="${cy}" r="4.5" class="chart-data-point" 
                  data-val="${val.toFixed(2)}" data-label="${labels[i]}" />
        `;
      }

      if (i % interval === 0 || i === dataPoints.length - 1) {
        xLabelsHtml += `
          <text x="${cx}" y="${height - 8}" class="chart-axis-text" text-anchor="middle">${labels[i]}</text>
        `;
      }
    });

    svg.innerHTML = `
      <defs>
        <linearGradient id="energyGradient" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#10B981" stop-opacity="0.35" />
          <stop offset="100%" stop-color="#10B981" stop-opacity="0.0" />
        </linearGradient>
      </defs>
      ${gridLinesHtml}
      <path d="${areaD}" class="chart-area-fill" />
      <path d="${pathD}" class="chart-line-stroke" />
      ${pointsHtml}
      ${xLabelsHtml}
    `;

    // Attach Tooltip events
    const tooltip = document.getElementById(svgId.replace('svg', 'tooltip'));
    if (!tooltip) return;

    svg.querySelectorAll('.chart-data-point').forEach(pt => {
      pt.addEventListener('mouseenter', (e) => {
        const val = pt.getAttribute('data-val');
        const lbl = pt.getAttribute('data-label');
        tooltip.innerHTML = `<strong>${lbl}</strong><br>${val} kWh`;
        const rect = svg.getBoundingClientRect();
        const ptRect = pt.getBoundingClientRect();
        tooltip.style.left = `${ptRect.left - rect.left + 5}px`;
        tooltip.style.top = `${ptRect.top - rect.top}px`;
        tooltip.classList.add('visible');
      });

      pt.addEventListener('mouseleave', () => {
        tooltip.classList.remove('visible');
      });
    });
  }

  function renderDashboardTrendChart() {
    let dataset = [];
    let labels = [];

    if (state.selectedFilter === '7D') {
      dataset = state.dailyReadings.slice(-7);
      labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    } else if (state.selectedFilter === '30D') {
      dataset = state.dailyReadings;
      labels = dataset.map((_, i) => `${i + 1}`);
    } else {
      // 90D simulated repetition
      dataset = [...state.dailyReadings, ...state.dailyReadings, ...state.dailyReadings];
      labels = dataset.map((_, i) => `${i + 1}`);
    }

    renderBezierChart('dashboard-chart-svg', dataset, labels, 240);
  }

  function renderConsumptionTrendChart() {
    renderBezierChart('consumption-trend-svg', state.dailyReadings.slice(-7), ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'], 250);
  }

  function renderHourlyProfileBarChart() {
    const svg = document.getElementById('hourly-chart-svg');
    if (!svg) return;

    const width = svg.clientWidth || 700;
    const height = 220;
    const padding = { top: 20, right: 20, bottom: 35, left: 45 };
    const chartWidth = width - padding.left - padding.right;
    const chartHeight = height - padding.top - padding.bottom;

    const readings = state.hourlyReadings;
    const maxKwh = Math.max(...readings.map(r => r.kwh)) * 1.2;

    const barWidth = Math.min(36, (chartWidth / readings.length) * 0.7);
    const gap = chartWidth / readings.length;

    let barsHtml = '';
    let labelsHtml = '';

    readings.forEach((item, i) => {
      const x = padding.left + (i * gap) + (gap - barWidth) / 2;
      const barH = (item.kwh / maxKwh) * chartHeight;
      const y = padding.top + chartHeight - barH;
      const color = item.isPeak ? 'var(--warning)' : 'var(--primary)';

      barsHtml += `
        <rect x="${x}" y="${y}" width="${barWidth}" height="${barH}" rx="4" fill="${color}"
              style="transition: all 0.3s ease; cursor: pointer;"
              data-label="${item.label}" data-kwh="${item.kwh}" data-peak="${item.isPeak}">
          <title>${item.label}: ${item.kwh} kWh ${item.isPeak ? '(Peak Hour)' : ''}</title>
        </rect>
      `;

      labelsHtml += `
        <text x="${x + barWidth / 2}" y="${height - 8}" class="chart-axis-text" text-anchor="middle">
          ${item.label}
        </text>
      `;
    });

    // Y grid
    let gridHtml = '';
    for (let i = 0; i <= 3; i++) {
      const val = (i / 3) * maxKwh;
      const y = padding.top + chartHeight - (val / maxKwh) * chartHeight;
      gridHtml += `
        <line x1="${padding.left}" y1="${y}" x2="${width - padding.right}" y2="${y}" class="chart-grid-line" />
        <text x="${padding.left - 8}" y="${y + 4}" class="chart-axis-text" text-anchor="end">${val.toFixed(1)}</text>
      `;
    }

    svg.innerHTML = gridHtml + barsHtml + labelsHtml;
  }

  // --- Appliances Renderer ---
  function renderAppliancesList() {
    const container = document.getElementById('appliances-container');
    const searchVal = (document.getElementById('appliance-search')?.value || '').toLowerCase();
    const activeCategory = document.querySelector('.chip-btn.active')?.dataset.category || 'All';

    if (!container) return;

    const filtered = state.appliances.filter(app => {
      const matchesCat = activeCategory === 'All' || app.category === activeCategory;
      const matchesSearch = !searchVal || app.name.toLowerCase().includes(searchVal) || app.category.toLowerCase().includes(searchVal);
      return matchesCat && matchesSearch;
    });

    if (filtered.length === 0) {
      container.innerHTML = `
        <div style="grid-column: 1/-1; text-align: center; padding: 48px; color: var(--text-muted);">
          <span class="material-symbols-rounded" style="font-size: 48px; margin-bottom: 8px;">search_off</span>
          <h3>No appliances match your criteria</h3>
          <p style="font-size: 0.88rem;">Try clearing your search query or choosing another category filter.</p>
        </div>
      `;
      return;
    }

    container.innerHTML = filtered.map(app => {
      const isHighUsage = app.percentage >= 30;
      return `
        <div class="card appliance-card" onclick="window.energyApp.openApplianceDetails('${app.id}')">
          <div class="appliance-card-top">
            <div class="appliance-header-info">
              <div class="appliance-icon-box">
                <span class="material-symbols-rounded">${app.icon}</span>
              </div>
              <div>
                <div class="appliance-name">${app.name}</div>
                <div class="appliance-cat">${app.category}</div>
              </div>
            </div>
            <div class="status-pill ${app.isActive ? 'active' : ''}">
              <span class="pulse-dot" style="display: ${app.isActive ? 'inline-block' : 'none'};"></span>
              ${app.isActive ? 'Active' : 'Standby'}
            </div>
          </div>

          <div class="appliance-metrics-row">
            <div>
              <div class="metric-col-title">Power</div>
              <div class="metric-col-val">${app.powerKw} kW</div>
            </div>
            <div>
              <div class="metric-col-title">Daily Use</div>
              <div class="metric-col-val">${app.dailyHours} hrs</div>
            </div>
            <div>
              <div class="metric-col-title">Monthly</div>
              <div class="metric-col-val">${app.monthlyKwh} kWh</div>
            </div>
          </div>

          <div>
            <div style="display: flex; justify-content: space-between; font-size: 0.78rem; font-weight: 700; margin-bottom: 6px;">
              <span style="color: var(--text-secondary);">Household Share</span>
              <span style="color: ${isHighUsage ? 'var(--alert)' : 'var(--primary-light)'};">${app.percentage}%</span>
            </div>
            <div class="progress-track">
              <div class="progress-fill" style="width: ${app.percentage}%; background-color: ${isHighUsage ? 'var(--alert)' : 'var(--primary)'};"></div>
            </div>
          </div>

          <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 14px; padding-top: 10px; border-top: 1px solid var(--border-subtle);">
            <div style="font-size: 0.85rem; font-weight: 700; color: var(--text-primary);">
              Est: ${Format.currency(app.cost)}/mo
            </div>
            <button class="btn btn-text" style="font-size: 0.8rem; padding: 4px 8px;">
              Inspect <span class="material-symbols-rounded" style="font-size: 16px;">chevron_right</span>
            </button>
          </div>
        </div>
      `;
    }).join('');
  }

  // --- Top Appliances Mini List on Dashboard ---
  function renderDashboardTopAppliances() {
    const listEl = document.getElementById('dashboard-top-appliances');
    if (!listEl) return;

    const top4 = state.appliances.slice(0, 4);
    listEl.innerHTML = top4.map(app => {
      const isAlert = app.percentage >= 30;
      return `
        <div class="appliance-mini-row" onclick="window.energyApp.openApplianceDetails('${app.id}')">
          <div class="appliance-row-header">
            <div class="appliance-row-title">
              <span class="material-symbols-rounded" style="font-size: 18px; color: var(--primary);">${app.icon}</span>
              <span>${app.name}</span>
            </div>
            <div class="appliance-row-percentage" style="color: ${isAlert ? 'var(--alert)' : 'var(--primary)'};">
              ${app.percentage}%
            </div>
          </div>
          <div class="progress-track">
            <div class="progress-fill" style="width: ${app.percentage}%; background-color: ${isAlert ? 'var(--alert)' : 'var(--primary)'};"></div>
          </div>
        </div>
      `;
    }).join('');
  }

  // --- Savings Tips Renderer ---
  function renderSavingsTips() {
    const container = document.getElementById('savings-tips-container');
    if (!container) return;

    const adoptedCount = state.savingsTips.filter(t => t.isApplied).length;
    const progressEl = document.getElementById('savings-adopted-count');
    const progressBar = document.getElementById('savings-progress-bar');

    if (progressEl) progressEl.textContent = `${adoptedCount} of ${state.savingsTips.length} habits adopted`;
    if (progressBar) progressBar.style.width = `${(adoptedCount / state.savingsTips.length) * 100}%`;

    container.innerHTML = state.savingsTips.map(tip => {
      return `
        <div class="card savings-card ${tip.isApplied ? 'applied' : ''}">
          <div>
            <div class="savings-card-header">
              <div style="display: flex; align-items: center; gap: 10px;">
                <div class="stat-icon-wrapper" style="color: var(--primary);">
                  <span class="material-symbols-rounded">${tip.icon}</span>
                </div>
                <div>
                  <h4 style="font-weight: 800; font-size: 0.98rem;">${tip.title}</h4>
                  <div style="display: flex; gap: 6px; margin-top: 4px;">
                    <span class="badge-tag">${tip.category}</span>
                    <span class="badge-tag ${tip.difficulty.toLowerCase() === 'easy' ? 'badge-easy' : 'badge-medium'}">${tip.difficulty}</span>
                  </div>
                </div>
              </div>
            </div>

            <p style="font-size: 0.85rem; color: var(--text-secondary); margin: 12px 0 16px; line-height: 1.45;">
              ${tip.description}
            </p>
          </div>

          <div>
            <div style="display: flex; align-items: center; justify-content: space-between; padding: 10px 12px; background-color: var(--surface-variant); border-radius: var(--radius-sm); margin-bottom: 12px;">
              <span style="font-size: 0.78rem; font-weight: 600; color: var(--text-secondary);">Potential Savings</span>
              <span style="font-size: 0.95rem; font-weight: 800; color: var(--success);">${Format.currency(tip.estimatedSaving)} / mo (${tip.reductionPercent}%)</span>
            </div>

            <div style="display: flex; gap: 8px;">
              <button class="btn btn-outlined" style="flex: 1; font-size: 0.82rem; padding: 8px 12px;" onclick="window.energyApp.openTipSteps('${tip.id}')">
                <span class="material-symbols-rounded" style="font-size: 16px;">list_alt</span> View Steps
              </button>
              <button class="btn ${tip.isApplied ? 'btn-primary' : 'btn-tonal'}" style="flex: 1; font-size: 0.82rem; padding: 8px 12px;" onclick="window.energyApp.toggleTipApplied('${tip.id}')">
                <span class="material-symbols-rounded" style="font-size: 16px;">${tip.isApplied ? 'check_circle' : 'add_circle'}</span>
                ${tip.isApplied ? 'Adopted' : 'Mark as Applied'}
              </button>
            </div>
          </div>
        </div>
      `;
    }).join('');
  }

  // --- Bill Estimator Interactive Logic ---
  function updateBillEstimate(showToast = false) {
    const kwh = parseFloat(document.getElementById('bill-input-kwh')?.value) || 184.5;
    const rate = parseFloat(document.getElementById('bill-input-rate')?.value) || 8.0;
    const fixed = parseFloat(document.getElementById('bill-input-fixed')?.value) || 100.0;
    const tax = parseFloat(document.getElementById('bill-input-tax')?.value) || 0.0;
    const isSlab = state.billing.isSlabBilling;

    const breakdown = Computations.calculateBill(kwh, rate, fixed, tax, isSlab);

    const totalEl = document.getElementById('bill-hero-total');
    const energyChargeEl = document.getElementById('bill-breakdown-energy');
    const fixedChargeEl = document.getElementById('bill-breakdown-fixed');
    const taxChargeEl = document.getElementById('bill-breakdown-tax');
    const diffEl = document.getElementById('bill-comparison-diff');

    if (totalEl) totalEl.textContent = Format.currencyExact(breakdown.total);
    if (energyChargeEl) energyChargeEl.textContent = Format.currencyExact(breakdown.energyCharge);
    if (fixedChargeEl) fixedChargeEl.textContent = Format.currencyExact(breakdown.fixedCharge);
    if (taxChargeEl) taxChargeEl.textContent = Format.currencyExact(breakdown.taxCharge);

    // Baseline last month (201.7 kWh * 8 + 100 = 1713.6)
    const lastMonthBill = (201.7 * rate) + fixed;
    const diff = breakdown.total - lastMonthBill;
    if (diffEl) {
      const isSaving = diff <= 0;
      diffEl.textContent = `${isSaving ? '↓' : '↑'} ${Format.currencyExact(Math.abs(diff))} vs last month`;
      diffEl.className = `badge-tag ${isSaving ? 'badge-easy' : 'badge-medium'}`;
    }

    window._lastBillBreakdown = breakdown;

    if (showToast) {
      showNotificationToast(`Projected Bill calculated: ${Format.currency(breakdown.total)}`);
    }
  }

  // --- Modals System ---
  function openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) modal.classList.add('active');
  }

  function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) modal.classList.remove('active');
  }

  // --- Toast Notifications ---
  function showNotificationToast(msg) {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.innerHTML = `<span class="material-symbols-rounded" style="color: var(--success); font-size: 18px;">check_circle</span> <span>${msg}</span>`;
    container.appendChild(toast);

    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateY(15px)';
      toast.style.transition = 'all 0.25s ease';
      setTimeout(() => toast.remove(), 250);
    }, 2800);
  }

  // --- Navigation & View Switching ---
  function switchTab(tabId) {
    state.activeTab = tabId;

    // Update nav links
    document.querySelectorAll('.nav-item').forEach(el => {
      if (el.dataset.tab === tabId) {
        el.classList.add('active');
      } else {
        el.classList.remove('active');
      }
    });

    // Update views
    document.querySelectorAll('.view-section').forEach(view => {
      if (view.id === `view-${tabId}`) {
        view.classList.add('active');
      } else {
        view.classList.remove('active');
      }
    });

    // Trigger tab-specific rendering
    if (tabId === 'dashboard') {
      renderDashboardTrendChart();
      renderDashboardTopAppliances();
    } else if (tabId === 'consumption') {
      renderConsumptionTrendChart();
      renderHourlyProfileBarChart();
    } else if (tabId === 'appliances') {
      renderAppliancesList();
    } else if (tabId === 'bill') {
      updateBillEstimate();
    } else if (tabId === 'savings') {
      renderSavingsTips();
    }

    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  // --- Appliance Details View / Modal ---
  function openApplianceDetails(appId) {
    const app = state.appliances.find(a => a.id === appId);
    if (!app) return;

    const modal = document.getElementById('appliance-detail-modal');
    if (!modal) return;

    document.getElementById('modal-app-icon').textContent = app.icon;
    document.getElementById('modal-app-name').textContent = app.name;
    document.getElementById('modal-app-category').textContent = app.category;
    document.getElementById('modal-app-status').textContent = app.isActive ? 'Active' : 'Standby';
    document.getElementById('modal-app-status').className = `status-pill ${app.isActive ? 'active' : ''}`;

    document.getElementById('modal-metric-power').textContent = `${app.powerKw} kW`;
    document.getElementById('modal-metric-hours').textContent = `${app.dailyHours} hrs`;
    document.getElementById('modal-metric-monthly').textContent = `${app.monthlyKwh} kWh`;
    document.getElementById('modal-metric-cost').textContent = Format.currency(app.cost);

    document.getElementById('modal-app-score').textContent = `${app.efficiencyScore}%`;
    document.getElementById('modal-app-score-bar').style.width = `${app.efficiencyScore}%`;
    document.getElementById('modal-app-recommendation').textContent = app.recommendation;

    // 7-day mini bar chart inside modal
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const maxDayVal = Math.max(...app.weeklyKwh) * 1.15;
    const weeklyChartHtml = app.weeklyKwh.map((val, idx) => {
      const hPercent = (val / maxDayVal) * 100;
      return `
        <div style="flex: 1; display: flex; flex-direction: column; align-items: center; gap: 4px;">
          <div style="font-size: 0.68rem; font-weight: 700; color: var(--text-muted);">${val}</div>
          <div style="height: 70px; width: 100%; display: flex; align-items: flex-end; background: var(--surface-variant); border-radius: 4px;">
            <div style="width: 100%; height: ${hPercent}%; background: var(--primary); border-radius: 4px;"></div>
          </div>
          <div style="font-size: 0.72rem; font-weight: 600; color: var(--text-secondary);">${days[idx]}</div>
        </div>
      `;
    }).join('');
    document.getElementById('modal-weekly-bars').innerHTML = weeklyChartHtml;

    // Initialize Interactive Runtime Simulator Slider
    const slider = document.getElementById('modal-runtime-slider');
    const hoursVal = document.getElementById('modal-sim-hours-val');
    const simKwh = document.getElementById('modal-sim-kwh');
    const simCost = document.getElementById('modal-sim-cost');
    const simDiff = document.getElementById('modal-sim-diff');

    slider.value = app.dailyHours;
    hoursVal.textContent = `${app.dailyHours.toFixed(1)} hrs/day`;

    function recalculateSimulator(hours) {
      hoursVal.textContent = `${hours.toFixed(1)} hrs/day`;
      const dailyKwh = app.powerKw * hours;
      const monthlyKwh = dailyKwh * 30.0;
      const projectedCost = monthlyKwh * state.billing.ratePerKwh;
      const diff = projectedCost - app.cost;

      simKwh.textContent = `${monthlyKwh.toFixed(1)} kWh/mo`;
      simCost.textContent = Format.currency(projectedCost);

      if (diff > 0) {
        simDiff.textContent = `+${Format.currency(diff)} vs current`;
        simDiff.style.color = 'var(--alert)';
      } else if (diff < 0) {
        simDiff.textContent = `-${Format.currency(Math.abs(diff))} savings`;
        simDiff.style.color = 'var(--success)';
      } else {
        simDiff.textContent = `No change`;
        simDiff.style.color = 'var(--text-muted)';
      }
    }

    slider.oninput = (e) => recalculateSimulator(parseFloat(e.target.value));
    recalculateSimulator(app.dailyHours);

    openModal('appliance-detail-modal');
  }

  // --- Public API for HTML Event Binding ---
  window.energyApp = {
    switchTab,
    applyTheme,
    openModal,
    closeModal,
    openApplianceDetails,

    toggleTheme: () => {
      const nextTheme = state.theme === 'dark' ? 'light' : 'dark';
      applyTheme(nextTheme);
    },

    setFilter: (filterId) => {
      state.selectedFilter = filterId;
      document.querySelectorAll('#dashboard-range-pills .pill-btn').forEach(btn => {
        btn.classList.toggle('active', btn.dataset.filter === filterId);
      });
      renderDashboardTrendChart();
    },

    setSimulationSpeed: (speed) => {
      state.simulationSpeed = speed;
      document.querySelectorAll('#sim-speed-selector .segmented-option').forEach(btn => {
        btn.classList.toggle('selected', btn.dataset.speed === speed);
      });
      startSimulation();
      updateLivePowerUI();
      showNotificationToast(`Simulation speed set to: ${speed.toUpperCase()}`);
    },

    setTariffMode: (mode) => {
      state.billing.isSlabBilling = (mode === 'slab');
      document.querySelectorAll('#tariff-mode-toggle .segmented-option').forEach(opt => {
        opt.classList.toggle('selected', opt.dataset.mode === mode);
      });

      const rateGroup = document.getElementById('rate-input-group');
      if (rateGroup) {
        rateGroup.style.display = (mode === 'slab') ? 'none' : 'block';
      }

      updateBillEstimate(false);
    },

    calculateBill: () => {
      updateBillEstimate(true);
    },

    useCurrentConsumption: () => {
      const input = document.getElementById('bill-input-kwh');
      if (input) {
        input.value = '184.5';
        updateBillEstimate(true);
      }
    },

    showSlabBreakdownModal: () => {
      const breakdown = window._lastBillBreakdown || Computations.calculateBill(184.5, 8.0, 100.0, 0.0, state.billing.isSlabBilling);
      const container = document.getElementById('slab-breakdown-details');
      if (!container) return;

      if (!breakdown.isSlab) {
        container.innerHTML = `
          <div style="padding: 16px; background-color: var(--surface-variant); border-radius: var(--radius-md);">
            <div style="font-weight: 700; margin-bottom: 8px;">Flat Single Tariff Computation</div>
            <div class="bill-row-item"><span>Consumption Units:</span><strong>${breakdown.consumption.toFixed(1)} kWh</strong></div>
            <div class="bill-row-item"><span>Electricity Rate:</span><strong>₹${state.billing.ratePerKwh.toFixed(2)} / unit</strong></div>
            <div class="bill-row-item"><span>Energy Charge:</span><strong>${Format.currencyExact(breakdown.energyCharge)}</strong></div>
            <div class="bill-row-item"><span>Fixed Meter Charge:</span><strong>${Format.currencyExact(breakdown.fixedCharge)}</strong></div>
            <div class="bill-row-item total"><span>Total Payable:</span><strong style="color: var(--primary);">${Format.currencyExact(breakdown.total)}</strong></div>
          </div>
        `;
      } else {
        container.innerHTML = `
          <div style="margin-bottom: 12px; font-weight: 700;">Progressive Tier Computation (${breakdown.consumption.toFixed(1)} Units):</div>
          <div style="background-color: var(--surface-variant); border-radius: var(--radius-md); padding: 12px; margin-bottom: 14px;">
            ${breakdown.slabs.map(slab => `
              <div class="bill-row-item">
                <div>
                  <div style="font-weight: 600;">${slab.label}</div>
                  <div style="font-size: 0.75rem; color: var(--text-muted);">${slab.units.toFixed(1)} units @ ₹${slab.rate.toFixed(2)}</div>
                </div>
                <strong>${Format.currencyExact(slab.cost)}</strong>
              </div>
            `).join('')}
          </div>
          <div class="bill-row-item"><span>Energy Charges Subtotal:</span><strong>${Format.currencyExact(breakdown.energyCharge)}</strong></div>
          <div class="bill-row-item"><span>Fixed Meter Maintenance Fee:</span><strong>${Format.currencyExact(breakdown.fixedCharge)}</strong></div>
          <div class="bill-row-item"><span>Taxes & Duties:</span><strong>${Format.currencyExact(breakdown.taxCharge)}</strong></div>
          <div class="bill-row-item total"><span>Total Bill:</span><strong style="color: var(--primary); font-size: 1.15rem;">${Format.currencyExact(breakdown.total)}</strong></div>
        `;
      }

      openModal('bill-calculation-modal');
    },

    openTipSteps: (tipId) => {
      const tip = state.savingsTips.find(t => t.id === tipId);
      if (!tip) return;

      document.getElementById('tip-modal-icon').textContent = tip.icon;
      document.getElementById('tip-modal-title').textContent = tip.title;
      document.getElementById('tip-modal-saving').textContent = `Potential Saving: ${Format.currency(tip.estimatedSaving)} / month (-${tip.reductionPercent}%)`;

      const stepsHtml = tip.steps.map((st, i) => `
        <div style="display: flex; gap: 10px; margin-bottom: 10px; font-size: 0.88rem; line-height: 1.45;">
          <div style="width: 22px; height: 22px; border-radius: 50%; background: var(--primary-container); color: var(--primary); display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 0.75rem; flex-shrink: 0;">${i + 1}</div>
          <div>${st}</div>
        </div>
      `).join('');

      document.getElementById('tip-modal-steps').innerHTML = stepsHtml;
      openModal('tip-steps-modal');
    },

    toggleTipApplied: (tipId) => {
      const tip = state.savingsTips.find(t => t.id === tipId);
      if (!tip) return;

      tip.isApplied = !tip.isApplied;
      renderSavingsTips();
      showNotificationToast(tip.isApplied ? `Habit "${tip.title}" marked as Adopted!` : `Habit updated`);
    },

    filterCategory: (category, btn) => {
      document.querySelectorAll('.chips-bar .chip-btn').forEach(c => c.classList.remove('active'));
      btn.classList.add('active');
      renderAppliancesList();
    },

    resetDemoData: () => {
      state = JSON.parse(JSON.stringify(DEFAULT_STATE));
      state.lastUpdated = new Date();
      applyTheme(state.theme);
      startSimulation();
      updateLivePowerUI();
      switchTab('dashboard');
      closeModal('settings-modal');
      closeModal('reset-confirm-modal');
      showNotificationToast('Demo presentation data restored to default (184.5 kWh)!');
    }
  };

  // --- Initial Setup on DOMContentLoaded ---
  document.addEventListener('DOMContentLoaded', () => {
    applyTheme(state.theme);
    startSimulation();
    updateLivePowerUI();
    renderDashboardTrendChart();
    renderDashboardTopAppliances();

    // Responsive SVG resize watcher
    window.addEventListener('resize', () => {
      if (state.activeTab === 'dashboard') renderDashboardTrendChart();
      if (state.activeTab === 'consumption') {
        renderConsumptionTrendChart();
        renderHourlyProfileBarChart();
      }
    });

    // Close modals on clicking overlay backdrop
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
      overlay.addEventListener('click', (e) => {
        if (e.target === overlay) {
          overlay.classList.remove('active');
        }
      });
    });
  });

})();
