/**
 ******************************************************************************
 * @file      startup_gd32l23x.s
 * @author    Giulio Dalla Vecchia
 * @brief     GD32L233C device vector table for GCC toolchain.
 *            This module performs:
 *                - Set the initial SP
 *                - Set the initial PC == Reset_Handler,
 *                - Set the vector table entries with the exceptions ISR address
 *                - Branches to main in the C library (which eventually
 *                  calls main()).
 ******************************************************************************
 * @attention
 *
 * Copyright (c) 2022 Giulio Dalla Vecchia
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 * If no LICENSE file comes with this software, it is provided AS-IS.
 *
 ******************************************************************************
 */

  .syntax unified
  .cpu cortex-m23
  .thumb

.global  g_pfnVectors
.global  Default_Handler

/* start address of the static initialization data */
.word  _sidata
/* start address of the data section */
.word  _sdata
/* end address of the data section */
.word  _edata
/* start address of the bss section */
.word  _sbss
/* end address of the bss section */
.word  _ebss


  .section .text.Reset_Handler
  .weak Reset_Handler
  .type Reset_Handler, %function
Reset_Handler:
  ldr   r0, =_estack
  mov   sp, r0          /* set stack pointer */
/* Call the clock system initialization function.*/
  bl  SystemInit

/* Copy the data segment initializers from flash to SRAM */
  ldr r0, =_sdata
  ldr r1, =_edata
  ldr r2, =_sidata
  movs r3, #0
  b LoopCopyDataInit

CopyDataInit:
  ldr r4, [r2, r3]
  str r4, [r0, r3]
  adds r3, r3, #4

LoopCopyDataInit:
  adds r4, r0, r3
  cmp r4, r1
  bcc CopyDataInit

/* Zero fill the bss segment. */
  ldr r2, =_sbss
  ldr r4, =_ebss
  movs r3, #0
  b LoopFillZerobss

FillZerobss:
  str  r3, [r2]
  adds r2, r2, #4

LoopFillZerobss:
  cmp r2, r4
  bcc FillZerobss

/* Call static constructors */
  bl __libc_init_array
/* start execution of the program */
  bl main
  bx lr

LoopForever:
    b LoopForever

  .size Reset_Handler, .-Reset_Handler

/**
 * @brief  This is the code that gets called when the processor receives an
 *         unexpected interrupt.  This simply enters an infinite loop, preserving
 *         the system state for examination by a debugger.
 *
 * @param  None
 * @retval : None
*/
  .section .text.Default_Handler,"ax",%progbits
Default_Handler:
Infinite_Loop:
  b Infinite_Loop
  .size Default_Handler, .-Default_Handler

/******************************************************************************
*
* The STM32H725ZGTx vector table.  Note that the proper constructs
* must be placed on this to ensure that it ends up at physical address
* 0x0000.0000.
*
******************************************************************************/
  .section .isr_vector,"a",%progbits
  .type g_pfnVectors, %object
  .size g_pfnVectors, .-g_pfnVectors

g_pfnVectors:
  .word _estack
  .word Reset_Handler
  .word NMI_Handler
  .word HardFault_Handler
  .word	0
  .word	0
  .word	0
  .word	0
  .word	0
  .word	0
  .word	0
  .word	SVC_Handler
  .word	0
  .word	0
  .word	PendSV_Handler
  .word	SysTick_Handler

  /* external interrupts handler */
  .word	WWDGT_IRQHandler                 			/* Window Watchdog interrupt                   */
  .word	LVD_IRQHandler               			/* PVD through EXTI line                       */
  .word	TAMPER_STAMP_IRQHandler			/* RTC tamper, timestamp                       */
  .word	RTC_WKUP_IRQHandler              			/* RTC Wakeup interrupt                        */
  .word	FMC_IRQHandler                 			/* Flash memory                                */
  .word	RCU_CTC_IRQHandler                   			/* RCC global interrupt                        */
  .word	EXTI0_IRQHandler                 			/* EXTI Line 0 interrupt                       */
  .word	EXTI1_IRQHandler                 			/* EXTI Line 1 interrupt                       */
  .word	EXTI2_IRQHandler                 			/* EXTI Line 2 interrupt                       */
  .word	EXTI3_IRQHandler                 			/* EXTI Line 3interrupt                        */
  .word	EXTI4_IRQHandler                 			/* EXTI Line 4interrupt                        */
  .word	DMA_Channel0_IRQHandler              			/* DMA1 Stream0                                */
  .word	DMA_Channel1_IRQHandler              			/* DMA1 Stream1                                */
  .word	DMA_Channel2_IRQHandler              			/* DMA1 Stream2                                */
  .word	DMA_Channel3_IRQHandler              			/* DMA1 Stream3                                */
  .word	DMA_Channel4_IRQHandler              			/* DMA1 Stream4                                */
  .word	DMA_Channel5_IRQHandler              			/* DMA1 Stream5                                */
  .word	DMA_Channel6_IRQHandler              			/* DMA1 Stream6                                */
  .word	ADC_IRQHandler                			/* ADC1 and ADC2                               */
  .word	USBD_HP_IRQHandler            			/* FDCAN1 Interrupt 0                          */
  .word	USBD_LP_IRQHandler            			/* FDCAN2 Interrupt 0                          */
  .word	TIMER1_IRQHandler            			/* FDCAN1 Interrupt 1                          */
  .word	TIMER2_IRQHandler            			/* FDCAN2 Interrupt 1                          */
  .word	TIMER8_IRQHandler               			/* EXTI Line[9:5] interrupts                   */
  .word	TIMER11_IRQHandler              			/* TIM1 break interrupt                        */
  .word	TIMER5_IRQHandler               			/* TIM1 update interrupt                       */
  .word	TIMER6_IRQHandler          			/* TIM1 trigger and commutation                */
  .word	USART0_IRQHandler                			/* TIM1 capture / compare                      */
  .word	USART1_IRQHandler                  			/* TIM2 global interrupt                       */
  .word	UART3_IRQHandler                  			/* TIM3 global interrupt                       */
  .word	UART4_IRQHandler                  			/* TIM4 global interrupt                       */
  .word	I2C0_EV_IRQHandler               			/* I2C1 event interrupt                        */
  .word	I2C0_ER_IRQHandler               			/* I2C1 global error interrupt                 */
  .word	I2C1_EV_IRQHandler               			/* I2C2 event interrupt                        */
  .word	I2C1_ER_IRQHandler               			/* I2C2 global error interrupt                 */
  .word	SPI0_IRQHandler                  			/* SPI1 global interrupt                       */
  .word	SPI1_IRQHandler                  			/* SPI2 global interrupt                       */
  .word	DAC_IRQHandler                			/* USART1 global interrupt                     */
  .word	0                			/* USART2 global interrupt                     */
  .word	I2C2_EV_IRQHandler                			/* USART3 global interrupt                     */
  .word	I2C2_ER_IRQHandler             			/* EXTI Line[15:10] interrupts                 */
  .word	RTC_Alarm_IRQHandler             			/* RTC alarms (A and B)                        */
  .word	USBD_WKUP_IRQHandler                                			/* Reserved                                    */
  .word	EXTI5_9_IRQHandler        			/* TIM8 and 12 break global                    */
  .word	0         			/* TIM8 and 13 update global                   */
  .word	0    			/* TIM8 and 14 trigger /commutation and global */
  .word	0               			/* TIM8 capture / compare                      */
  .word	EXTI10_15_IRQHandler             			/* DMA1 Stream7                                */
  .word	0                   			/* FMC global interrupt                        */
  .word	0                			/* SDMMC1 global interrupt                     */
  .word	0                  			/* TIM5 global interrupt                       */
  .word	0                  			/* SPI3 global interrupt                       */
  .word	0                 			/* UART4 global interrupt                      */
  .word	0                 			/* UART5 global interrupt                      */
  .word	0              			/* TIM6 global interrupt                       */
  .word	DMAMUX_IRQHandler                  			/* TIM7 global interrupt                       */
  .word	CMP0_IRQHandler             			/* DMA2 Stream0 interrupt                      */
  .word	CMP1_IRQHandler             			/* DMA2 Stream1 interrupt                      */
  .word	I2C0_WKUP_IRQHandler             			/* DMA2 Stream2 interrupt                      */
  .word	I2C2_WKUP_IRQHandler             			/* DMA2 Stream3 interrupt                      */
  .word	USART0_WKUP_IRQHandler             			/* DMA2 Stream4 interrupt                      */
  .word	LPUART_IRQHandler                   			/* Ethernet global interrupt                   */
  .word	CAU_IRQHandler              			/* Ethernet wakeup through EXTI                */
  .word	TRNG_IRQHandler             			/* CAN2TX interrupts                           */
  .word	SLCD_IRQHandler                                			/* Reserved                                    */
  .word	USART1_WKUP_IRQHandler                                			/* Reserved                                    */
  .word	I2C1_WKUP_IRQHandler                                			/* Reserved                                    */
  .word	LPUART_WKUP_IRQHandler                                			/* Reserved                                    */
  .word	LPTIMER_IRQHandler             			/* DMA2 Stream5 interrupt                      */
/*******************************************************************************
*
* Provide weak aliases for each Exception handler to the Default_Handler.
* As they are weak aliases, any function with the same name will override
* this definition.
*
*******************************************************************************/

	.weak	NMI_Handler
	.thumb_set NMI_Handler,Default_Handler

	.weak	HardFault_Handler
	.thumb_set HardFault_Handler,Default_Handler

	.weak	SVC_Handler
	.thumb_set SVC_Handler,Default_Handler

	.weak	PendSV_Handler
	.thumb_set PendSV_Handler,Default_Handler

	.weak	SysTick_Handler
	.thumb_set SysTick_Handler,Default_Handler

	.weak	WWDGT_IRQHandler
	.thumb_set WWDGT_IRQHandler,Default_Handler

	.weak	LVD_IRQHandler
	.thumb_set LVD_IRQHandler,Default_Handler

	.weak	TAMPER_STAMP_IRQHandler
	.thumb_set TAMPER_STAMP_IRQHandler,Default_Handler

	.weak	RTC_WKUP_IRQHandler
	.thumb_set RTC_WKUP_IRQHandler,Default_Handler

	.weak	FMC_IRQHandler
	.thumb_set FMC_IRQHandler,Default_Handler

	.weak	RCU_CTC_IRQHandler
	.thumb_set RCU_CTC_IRQHandler,Default_Handler

	.weak	EXTI0_IRQHandler
	.thumb_set EXTI0_IRQHandler,Default_Handler

	.weak	EXTI1_IRQHandler
	.thumb_set EXTI1_IRQHandler,Default_Handler

	.weak	EXTI2_IRQHandler
	.thumb_set EXTI2_IRQHandler,Default_Handler

	.weak	EXTI3_IRQHandler
	.thumb_set EXTI3_IRQHandler,Default_Handler

	.weak	EXTI4_IRQHandler
	.thumb_set EXTI4_IRQHandler,Default_Handler

	.weak	DMA_Channel0_IRQHandler
	.thumb_set DMA_Channel0_IRQHandler,Default_Handler

	.weak	DMA_Channel1_IRQHandler
	.thumb_set DMA_Channel1_IRQHandler,Default_Handler

	.weak	DMA_Channel2_IRQHandler
	.thumb_set DMA_Channel2_IRQHandler,Default_Handler

	.weak	DMA_Channel3_IRQHandler
	.thumb_set DMA_Channel3_IRQHandler,Default_Handler

	.weak	DMA_Channel4_IRQHandler
	.thumb_set DMA_Channel4_IRQHandler,Default_Handler

	.weak	DMA_Channel5_IRQHandler
	.thumb_set DMA_Channel5_IRQHandler,Default_Handler

	.weak	DMA_Channel6_IRQHandler
	.thumb_set DMA_Channel6_IRQHandler,Default_Handler

	.weak	ADC_IRQHandler
	.thumb_set ADC_IRQHandler,Default_Handler

	.weak	USBD_HP_IRQHandler
	.thumb_set USBD_HP_IRQHandler,Default_Handler

	.weak	USBD_LP_IRQHandler
	.thumb_set USBD_LP_IRQHandler,Default_Handler

	.weak	TIMER1_IRQHandler
	.thumb_set TIMER1_IRQHandler,Default_Handler

	.weak	TIMER2_IRQHandler
	.thumb_set TIMER2_IRQHandler,Default_Handler

	.weak	TIMER8_IRQHandler
	.thumb_set TIMER8_IRQHandler,Default_Handler

	.weak	TIMER11_IRQHandler
	.thumb_set TIMER11_IRQHandler,Default_Handler

	.weak	TIMER5_IRQHandler
	.thumb_set TIMER5_IRQHandler,Default_Handler

	.weak	TIMER6_IRQHandler
	.thumb_set TIMER6_IRQHandler,Default_Handler

	.weak	USART0_IRQHandler
	.thumb_set USART0_IRQHandler,Default_Handler

	.weak	USART1_IRQHandler
	.thumb_set USART1_IRQHandler,Default_Handler

	.weak	UART3_IRQHandler
	.thumb_set UART3_IRQHandler,Default_Handler

	.weak	UART4_IRQHandler
	.thumb_set UART4_IRQHandler,Default_Handler

	.weak	I2C0_EV_IRQHandler
	.thumb_set I2C0_EV_IRQHandler,Default_Handler

	.weak	I2C0_ER_IRQHandler
	.thumb_set I2C0_ER_IRQHandler,Default_Handler

	.weak	I2C1_EV_IRQHandler
	.thumb_set I2C1_EV_IRQHandler,Default_Handler

	.weak	I2C1_ER_IRQHandler
	.thumb_set I2C1_ER_IRQHandler,Default_Handler

	.weak	SPI0_IRQHandler
	.thumb_set SPI0_IRQHandler,Default_Handler

	.weak	SPI1_IRQHandler
	.thumb_set SPI1_IRQHandler,Default_Handler

	.weak	DAC_IRQHandler
	.thumb_set DAC_IRQHandler,Default_Handler

	.weak	I2C2_EV_IRQHandler
	.thumb_set I2C2_EV_IRQHandler,Default_Handler

	.weak	I2C2_ER_IRQHandler
	.thumb_set I2C2_ER_IRQHandler,Default_Handler

	.weak	RTC_Alarm_IRQHandler
	.thumb_set RTC_Alarm_IRQHandler,Default_Handler

	.weak	USBD_WKUP_IRQHandler
	.thumb_set USBD_WKUP_IRQHandler,Default_Handler

	.weak	EXTI5_9_IRQHandler
	.thumb_set EXTI5_9_IRQHandler,Default_Handler

	.weak	EXTI10_15_IRQHandler
	.thumb_set EXTI10_15_IRQHandler,Default_Handler

	.weak	DMAMUX_IRQHandler
	.thumb_set DMAMUX_IRQHandler,Default_Handler

	.weak	CMP0_IRQHandler
	.thumb_set CMP0_IRQHandler,Default_Handler

	.weak	CMP1_IRQHandler
	.thumb_set CMP1_IRQHandler,Default_Handler

	.weak	I2C0_WKUP_IRQHandler
	.thumb_set I2C0_WKUP_IRQHandler,Default_Handler

	.weak	I2C2_WKUP_IRQHandler
	.thumb_set I2C2_WKUP_IRQHandler,Default_Handler

	.weak	USART0_WKUP_IRQHandler
	.thumb_set USART0_WKUP_IRQHandler,Default_Handler

	.weak	LPUART_IRQHandler
	.thumb_set LPUART_IRQHandler,Default_Handler

	.weak	CAU_IRQHandler
	.thumb_set CAU_IRQHandler,Default_Handler

	.weak	TRNG_IRQHandler
	.thumb_set TRNG_IRQHandler,Default_Handler

	.weak	SLCD_IRQHandler
	.thumb_set SLCD_IRQHandler,Default_Handler

	.weak	USART1_WKUP_IRQHandler
	.thumb_set USART1_WKUP_IRQHandler,Default_Handler

	.weak	I2C1_WKUP_IRQHandler
	.thumb_set I2C1_WKUP_IRQHandler,Default_Handler

	.weak	LPUART_WKUP_IRQHandler
	.thumb_set LPUART_WKUP_IRQHandler,Default_Handler

	.weak	LPTIMER_IRQHandler
	.thumb_set LPTIMER_IRQHandler,Default_Handler

	.weak	SystemInit

/************************ (C) COPYRIGHT STMicroelectonics *****END OF FILE****/
