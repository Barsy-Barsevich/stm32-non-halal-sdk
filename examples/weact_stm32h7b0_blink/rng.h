#pragma once

#include "main.h"

extern RNG_HandleTypeDef hrng;

void MX_RNG_Init(void);
void HAL_RNG_MspInit(RNG_HandleTypeDef *rngHandle);
void HAL_RNG_MspDeInit(RNG_HandleTypeDef *rngHandle);
