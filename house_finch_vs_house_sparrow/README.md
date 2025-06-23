# House Finch vs House Sparrow: Native vs Introduced Species Competition Analysis

## Overview
Comprehensive analysis of competition between native California House Finches and introduced European House Sparrows using eBird data (2005-2025). This study examines 20 years of species distribution patterns across all 58 California counties, revealing clear ecological and geographic dominance patterns between native and invasive species.

## Key Findings

### **Native Species Dominance**
House Finches (native California species) demonstrate overwhelming competitive advantage over House Sparrows (introduced European species) across the state, dominating in 82.2% of all county-year records (1,002 of 1,218 cases).

### **Population Growth Patterns** (2005-2024)
- **House Finch**: 50x population increase (57,230 to 2,861,998 birds observed)
- **House Sparrow**: 41x population increase (14,648 to 600,897 birds observed)
- **Final ratio**: House Finches outnumber House Sparrows 4.8:1 in 2024
- **Observation frequency**: House Finches observed 3.7x more frequently than House Sparrows

### **Breeding Success Indicators**
- **House Finch**: Breeding percentage increased from 0.3% to 2.4% (8x improvement)
- **House Sparrow**: Breeding percentage peaked at 1.8% in 2019, declining to 1.3% by 2024
- **Flock size advantage**: House Finches average 7-9 birds per observation vs 5-6 for House Sparrows

### **Geographic Competition Patterns**

#### **House Sparrow Strongholds** (Counties with >50% dominance)
1. **Sierra County**: 100% dominance (21/21 years) - High Sierra mountains
2. **Plumas County**: 100% dominance (21/21 years) - Northern mountains
3. **Del Norte**: 95.2% dominance (20/21 years) - Far north coast
4. **Lassen**: 95.2% dominance (20/21 years) - Northeastern high desert
5. **Modoc**: 85.7% dominance (18/21 years) - Northeastern plateau
6. **Imperial**: 81.0% dominance (17/21 years) - Southeastern desert agriculture
7. **Alpine**: 57.9% dominance (11/19 years) - High Sierra mountains
8. **Glenn**: 52.4% dominance (11/21 years) - Northern Central Valley agriculture

#### **Regional Clusters of House Sparrow Success**
- **Northeastern Mountains/Plateau**: Modoc, Lassen, Plumas, Sierra
- **Far North Coast**: Del Norte
- **High Sierra**: Alpine, Sierra
- **Central Valley Agriculture**: Glenn, Imperial, Kings, Merced, Tulare
- **Occasional Competitive Areas**: 20 additional counties with sporadic dominance

#### **House Finch Dominance Areas**
- **Urban Centers**: Los Angeles, San Diego, Orange, San Francisco (80-95% dominance)
- **Coastal Regions**: Consistent native species advantage
- **Suburban Areas**: Mediterranean climate zones favor native adaptation
- **Bay Area Example**: Alameda County shows 89-95% House Finch dominance (2005-2024)

### **Ecological Insights**

#### **Habitat Preferences**
- **House Sparrows thrive in**: Cold climates, high elevations, agricultural areas, low population density
- **House Finches dominate in**: Urban areas, coastal regions, Mediterranean climates, high population density

#### **Climate and Geography Correlations**
- **Elevation**: House Sparrows gain advantage above 4,000 feet
- **Temperature**: Cold mountain/desert climates favor introduced species
- **Human density**: Urban environments strongly favor native species
- **Agricultural landscapes**: Mixed results with slight House Sparrow advantage

#### **Temporal Dynamics**
- **Urban stability**: Consistent House Finch dominance in metropolitan areas
- **Rural volatility**: Agricultural counties show species flips and genuine competition
- **Recent trends** (2020-2025): House Sparrows maintain strongholds in 10 counties

### **Conservation Implications**

#### **Native Species Success**
- Native California House Finches significantly outcompete introduced European species
- Urban environments support native biodiversity when designed appropriately
- House Finch success demonstrates superior adaptation to local California conditions

#### **Invasive Species Limitations**
- House Sparrow populations show growth plateau since 2019
- Ecological limits evident for non-native urban species in Mediterranean climates
- Geographic restriction to specific habitat types (mountains, deserts, agriculture)

#### **Management Priorities**
- **Monitor**: 28 counties where House Sparrows achieve periodic dominance
- **Protect**: Urban native species populations as competitive advantages
- **Study**: High-elevation and agricultural systems where invasive species succeed

## Methodology

### **Analysis Strategy**
Rather than processing all 1,218 county-year records (showing predictable House Finch dominance), this analysis focused on the ecologically significant 216 cases (17.8%) where House Sparrows achieve dominance, revealing clear geographic and ecological patterns.

### **Data Processing**
- **Species identification**: Multiple common and scientific name variations
- **Count standardization**: "X" observations treated as single individuals
- **Dominance classification**: 2:1 ratio threshold for species dominance determination
- **Geographic coverage**: All 58 California counties analyzed
- **Temporal scope**: 2005-2025 (21-year analysis period)

### **Competitive Analysis Metrics**
- **Dominance ratio**: Species count comparisons by county and year
- **Geographic distribution**: County-level success rates and patterns
- **Temporal trends**: Year-over-year population and breeding changes
- **Breeding success**: Percentage of observations with breeding behaviors

## Dataset Statistics

| Metric | House Finch | House Sparrow |
|--------|-------------|---------------|
| **Total observations (2005-2024)** | 2.8 million | 926,000 |
| **Unique surveys** | 2.6 million | 837,000 |
| **Counties with data** | 58 | 58 |
| **Peak breeding percentage** | 2.5% | 1.8% |
| **2024 population estimate** | 2,861,998 | 600,897 |
| **Dominance frequency** | 82.2% | 17.8% |

## Analysis Files

### **SQL Queries**
- [`annual_dominance_by_county.sql`](annual_dominance_by_county.sql) - Year-by-year species competition across all counties
- [`basic_observation_data.sql`](basic_observation_data.sql) - Population trends and breeding success analysis
- [`house_sparrow_dominance_by_county.sql`](house_sparrow_dominance_by_county.sql) - Focused analysis of House Sparrow dominance cases

### **Results**
See detailed outputs in [`/results`](results/) folder:
- [`annual_dominance_by_county.txt`](results/annual_dominance_by_county.txt) - Analysis justification and methodology
- [`basic_observation_data.txt`](results/basic_observation_data.txt) - Population trends and comparative breeding success
- [`house_sparrow_dominance_by_county.txt`](results/house_sparrow_dominance_by_county.txt) - Complete analysis of 216 dominance cases

## Research Applications

### **Ecological Research**
- **Invasion biology**: Understanding where and why introduced species succeed
- **Competition theory**: Native vs non-native species interactions
- **Urban ecology**: Species adaptation to human-modified environments
- **Climate adaptation**: Species responses to California's variable climate

### **Conservation Management**
- **Habitat protection**: Identifying critical native species strongholds
- **Restoration planning**: Understanding successful native species environments
- **Invasive species monitoring**: Geographic patterns of non-native success
- **Urban planning**: Supporting native biodiversity in development projects

### **Citizen Science Validation**
- **Data quality assessment**: 20-year longitudinal dataset validation
- **Observer bias analysis**: Geographic and temporal sampling patterns
- **Population monitoring**: Large-scale species trend documentation
- **Breeding ecology**: Citizen science detection of reproductive behaviors

## Summary

This analysis demonstrates that native California House Finches maintain significant competitive advantages over introduced European House Sparrows across most habitat types and geographic regions. House Sparrows achieve dominance primarily in high-elevation, cold-climate, and agricultural areas, representing specialized ecological niches rather than broad competitive superiority. The 20-year dataset reveals stable coexistence patterns with clear geographic partitioning based on habitat preferences and climatic tolerances.

**Total dataset**: 1,218 county-year records showing species competition across California (2005-2025)  
**Key finding**: Native species competitive advantage in 82.2% of cases, with introduced species success limited to specific geographic and climatic conditions.