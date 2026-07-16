import localforage from 'localforage'

const STORE_KEY = 'ghanshyam.tasks.v1'

localforage.config({ name: 'Ghanshyam', storeName: 'ghanshyam_data' })

export async function loadTasks () {
  try {
    const data = await localforage.getItem(STORE_KEY)
    return data || []
  } catch (err) {
    console.error('loadTasks error', err)
    return []
  }
}

export async function saveTasks (tasks) {
  try {
    await localforage.setItem(STORE_KEY, tasks)
  } catch (err) {
    console.error('saveTasks error', err)
    throw err
  }
}
