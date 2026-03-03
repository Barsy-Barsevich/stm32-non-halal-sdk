#include "rtc.h"

RTC_HandleTypeDef hrtc;

void MX_RTC_Init(void)
{
	hrtc.Instance = RTC;
	hrtc.Init.HourFormat = RTC_HOURFORMAT_24;
	hrtc.Init.AsynchPrediv = 127;
	hrtc.Init.SynchPrediv = 255;
	hrtc.Init.OutPut = RTC_OUTPUT_DISABLE;
	hrtc.Init.OutPutPolarity = RTC_OUTPUT_POLARITY_HIGH;
	hrtc.Init.OutPutType = RTC_OUTPUT_TYPE_OPENDRAIN;
	hrtc.Init.OutPutRemap = RTC_OUTPUT_REMAP_NONE;
	if (HAL_RTC_Init(&hrtc) != HAL_OK)
	{
		Error_Handler();
	}
}

void HAL_RTC_MspInit(RTC_HandleTypeDef* rtcHandle)
{
	RCC_PeriphCLKInitTypeDef PeriphClkInitStruct = {0};
	if(rtcHandle->Instance==RTC)
	{
		PeriphClkInitStruct.PeriphClockSelection = RCC_PERIPHCLK_RTC;
		PeriphClkInitStruct.RTCClockSelection = RCC_RTCCLKSOURCE_LSE;
		if (HAL_RCCEx_PeriphCLKConfig(&PeriphClkInitStruct) != HAL_OK)
		{
			Error_Handler();
		}
		__HAL_RCC_RTC_ENABLE();
	}
}

void HAL_RTC_MspDeInit(RTC_HandleTypeDef* rtcHandle)
{
	if(rtcHandle->Instance==RTC)
	{
		__HAL_RCC_RTC_DISABLE();
	}
}
