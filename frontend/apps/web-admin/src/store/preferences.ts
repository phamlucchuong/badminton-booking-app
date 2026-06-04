import { create } from 'zustand'
import { persist } from 'zustand/middleware'

type ThemeMode = 'light' | 'dark'
type Language = 'EN' | 'VI'

interface PreferencesState {
  theme: ThemeMode
  language: Language
  toggleTheme: () => void
  toggleLanguage: () => void
}

export const usePreferencesStore = create<PreferencesState>()(
  persist(
    (set) => ({
      theme: 'light',
      language: 'VI',
      toggleTheme: () =>
        set((state) => ({
          theme: state.theme === 'dark' ? 'light' : 'dark',
        })),
      toggleLanguage: () =>
        set((state) => ({
          language: state.language === 'EN' ? 'VI' : 'EN',
        })),
    }),
    {
      name: 'badminton-admin-preferences',
    },
  ),
)
