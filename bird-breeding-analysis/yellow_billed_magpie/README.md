# Yellow-billed Magpie Breeding Analysis

## Overview
Analysis of Yellow-billed Magpie breeding patterns using eBird data (2013-2025). This endemic California species shows unique year-round breeding activity and active range expansion across 26 counties.

## Key Findings

### **Seasonal Breeding Patterns**

#### **Spring: Peak Breeding Season** (479 observations)
- **190 Nest Building** - Primary breeding season begins
- **169 Occupied Nests** - High nesting success rate  
- **120 Carrying Nesting Material** - Intensive preparation activity

#### **Summer: Post-Breeding Dispersal** (64 observations)
- **38 Recently Fledged Young** - Young birds leaving nests
- **17 Occupied Nests** - Late-season breeding attempts
- **9 Feeding Young** - Adults caring for dependent offspring

#### **Winter: Unexpected Activity** (158 observations)
- **75 Nest Building** - Surprising winter construction
- **52 Carrying Nesting Material** - Off-season preparation
- **31 Occupied Nests** - Potential mild-weather breeding

#### **Fall: Territory Maintenance** (46 observations)
- **21 Nest Building** - Continued territorial behavior
- **19 Carrying Nesting Material** - Preparation for winter
- **6 Occupied Nests** - Extended breeding season

### **Geographic Distribution & Range Expansion**

#### **Dramatic Range Expansion** (2020-2025)
- **14 counties** show recent colonization (first observed 2020+)
- **53.8% of all breeding counties** are newly established territories
- **Northward expansion** documented: Shasta (2024), Butte (2020), Nevada (2020)
- **Eastward expansion** into Sierra Nevada foothills: Calaveras, Amador, Nevada
- **Southern expansion** continues: Monterey, San Luis Obispo, Santa Barbara

#### **New Territory Success Patterns**
**🏆 Highly Successful New Colonies:**
- **Calaveras**: 100% success (2021 colonization, 35 observations)
- **Madera**: 100% success (2024 colonization, 15 observations)  
- **Colusa**: 66.7% success (2021-2025, 126 observations)
- **Yuba**: 50% success (2021-2023, 12 observations)

**⚠️ Struggling New Territories:**
- **Sutter**: 0% success (2022 only, 12 observations)
- **Amador**: 0% success (2021 only, 24 observations)
- **Placer**: 9.7% success (2020-2024, 105 observations)

#### **Established Population Centers**
**🎯 Core Breeding Areas:**
- **Sacramento**: 2,984 observations (Urban/Suburban, 34.3% success)
- **Yolo**: 752 observations (Rural, 33.6% success, 2013-2025)
- **Stanislaus**: 560 observations (Rural, 45.8% success, 2017-2025)

**🌟 High-Performing Stable Counties:**
- **San Luis Obispo**: 54.4% success (2018-2024, 155 observations)
- **Monterey**: 52.1% success (2016-2024, 168 observations)
- **San Benito**: 45.3% success (2016-2025, 175 observations)

#### **Conservation Status by Region**
- **Recent Colonization**: 14 counties (53.8%) - Active expansion phase
- **Stable Range**: 11 counties (42.3%) - Established breeding populations  
- **Possible Abandonment**: 1 county (3.8% - Contra Costa, 2013 only)

#### **Habitat Preferences**
- **Rural dominance**: 96.2% of breeding counties (25/26)
- **Limited urban adaptation**: Only Sacramento shows urban breeding success
- **Agricultural landscapes**: High success in Central Valley counties
- **Foothill expansion**: Growing presence in Sierra Nevada foothills

## Conservation Insights

**🔍 Seasonal Patterns:**
- **Year-round breeding activity** unlike most temperate birds
- **Spring dominance** with 7.5x more activity than summer
- **Winter nesting** suggests climate adaptation advantages

**🗺️ Geographic Expansion:**
- **Active northward expansion** with 53.8% of counties recently colonized
- **High success in new territories** indicates suitable habitat availability
- **Rural habitat preference** (96.2% of breeding locations)
- **Limited urban adaptation** (only Sacramento classified as urban)

**🌡️ Climate Adaptation:**
California's mild winters allow extended breeding seasons, giving Yellow-billed Magpies competitive advantages over migratory species.

**📊 Observer Detection:**
Summer's low numbers likely reflect **post-breeding dispersal** rather than reduced activity - mobile family groups are harder to detect than stationary nests.

## Breeding Code Distribution

| Code | Behavior | Count | % |
|------|----------|-------|---|
| NB | Nest Building | 294 | 26.0% |
| ON | Occupied Nest | 223 | 19.7% |
| CN | Carrying Nesting Material | 200 | 17.7% |
| FL | Recently Fledged Young | 142 | 12.6% |
| N | Territorial/Nesting | 114 | 10.1% |

*Total: 1,130 breeding observations (seasonal analysis)*

## Geographic Summary

| Metric | Value |
|--------|-------|
| **Counties with breeding activity** | 26 |
| **Total breeding observations** | 1,792 |
| **Years analyzed** | 2013-2025 |
| **Recent colonizations** | 14 counties |
| **Average success rate** | 33.2% |
| **Highest success rate** | 100% (Calaveras, Madera) |

## Analysis Files
- [`seasonal_breeding_patterns.sql`](seasonal_breeding_patterns.sql) - Seasonal analysis & breeding codes
- [`geographic_distribution.sql`](geographic_distribution.sql) - County-level success rates & range expansion
- [`data_validation.sql`](data_validation.sql) - Quality checks & breeding code validation

## Results
See detailed outputs in [`/results`](results/) folder:
- [`seasonal_breeding_patterns.txt`](results/seasonal_breeding_patterns.txt)
- [`geographic_distribution.txt`](results/geographic_distribution.txt)